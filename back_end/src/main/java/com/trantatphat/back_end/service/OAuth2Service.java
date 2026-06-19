package com.trantatphat.back_end.service;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

@Service
public class OAuth2Service {

    @Value("${google.client.id}")
    private String googleClientId;

    // Công cụ gọi API HTTP mặc định của Spring
    private final RestTemplate restTemplate = new RestTemplate();

    // 1. XÁC THỰC ID TOKEN CỦA GOOGLE (Dùng thư viện Google API Client)
    public Map<String, Object> verifyGoogleToken(String idTokenString) {
        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(), 
                    GsonFactory.getDefaultInstance()
            )
            // Ép Google phải kiểm tra xem Client ID đóng gói trong Token có trùng với Client ID của bạn không
            .setAudience(Collections.singletonList(googleClientId))
            .build();

            GoogleIdToken idToken = verifier.verify(idTokenString);
            
            if (idToken != null) {
                GoogleIdToken.Payload payload = idToken.getPayload();
                
                Map<String, Object> userInfo = new HashMap<>();
                userInfo.put("email", payload.getEmail());
                userInfo.put("name", payload.get("name"));
                return userInfo;
            } else {
                throw new RuntimeException("Mã Token Google không hợp lệ hoặc đã hết hạn!");
            }
        } catch (GeneralSecurityException | IOException e) {
            throw new RuntimeException("Lỗi xảy ra trong quá trình xác thực Token với Google: " + e.getMessage());
        }
    }

    // 2. XÁC THỰC ACCESS TOKEN CỦA FACEBOOK (Gọi HTTP trực tiếp sang Facebook Graph API)
    public Map<String, Object> verifyFacebookToken(String accessToken) {
        // Đường dẫn API của Facebook yêu cầu lấy thông tin id, name, email dựa vào token
        String facebookUrl = "https://graph.facebook.com/me?fields=id,name,email&access_token=" + accessToken;

        try {
            // Bắn một request GET sang server Facebook
            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                    facebookUrl,
                    HttpMethod.GET,
                    null,
                    new ParameterizedTypeReference<Map<String, Object>>() {}
            );

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                return response.getBody(); // Trả về Map chứa id, name, email do Facebook cung cấp
            } else {
                throw new RuntimeException("Facebook từ chối xác thực mã Token này!");
            }
        } catch (Exception e) {
            throw new RuntimeException("Lỗi kết nối mạng tới máy chủ Facebook: " + e.getMessage());
        }
    }
}
