package com.trantatphat.back_end.service;

import com.trantatphat.back_end.payload.request.LoginRequest;
import com.trantatphat.back_end.payload.request.RegisterRequest;
import com.trantatphat.back_end.payload.response.AuthResponse;
import com.trantatphat.back_end.entity.Provider;
import com.trantatphat.back_end.entity.User;
import com.trantatphat.back_end.repository.UserRepository;
import com.trantatphat.back_end.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final AuthenticationManager authenticationManager;
    private final OAuth2Service oAuth2Service;

    // 1. LOGIC ĐĂNG KÝ TÀI KHOẢN TRUYỀN THỐNG (LOCAL)
    public String register(RegisterRequest request) {
        // Kiểm tra xem email đã tồn tại trong PostgreSQL chưa
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email này đã được sử dụng!");
        }

        // Tạo đối tượng User mới và băm mật khẩu bằng BCrypt trước khi lưu
        User user = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword())) // Băm mật khẩu 1 chiều
                .provider(Provider.LOCAL) // Đánh dấu nguồn đăng ký là tài khoản cục bộ
                .build();

        userRepository.save(user);
        return "Đăng ký tài khoản thành công!";
    }

    // 2. LOGIC ĐĂNG NHẬP TRUYỀN THỐNG (EMAIL & PASSWORD)
    public AuthResponse login(LoginRequest request) {
        // Gọi AuthenticationManager để tự động kiểm tra email và so sánh mật khẩu đã băm
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );

        // Nếu không trùng khớp, dòng lệnh trên sẽ tự động ném ra ngoại lệ 401 Unauthorized.
        // Nếu thành công, lấy thông tin User ra để sinh mã token JWT
        User user = (User) authentication.getPrincipal();
        String jwtToken = jwtTokenProvider.generateToken(user);

        // Đóng gói dữ liệu trả về cho Flutter
        return AuthResponse.builder()
                .token(jwtToken)
                .name(user.getName())
                .email(user.getEmail())
                .build();
    }

    // 3. LOGIC XỬ LÝ ĐĂNG NHẬP BẰNG GOOGLE
    public AuthResponse loginWithGoogle(String googleToken) {
        Map<String, Object> googleUserInfo = oAuth2Service.verifyGoogleToken(googleToken);
        String email = (String) googleUserInfo.get("email");
        String name = (String) googleUserInfo.get("name");

        User user = processOAuth2User(email, name, Provider.GOOGLE, true);
        String jwtToken = jwtTokenProvider.generateToken(user);
        return AuthResponse.builder().token(jwtToken).name(user.getName()).email(user.getEmail()).build();
    }

    // 4. LOGIC XỬ LÝ ĐĂNG KÝ BẰNG GOOGLE
    public AuthResponse registerWithGoogle(String googleToken) {
        Map<String, Object> googleUserInfo = oAuth2Service.verifyGoogleToken(googleToken);
        String email = (String) googleUserInfo.get("email");
        String name = (String) googleUserInfo.get("name");

        User user = processOAuth2User(email, name, Provider.GOOGLE, false);
        String jwtToken = jwtTokenProvider.generateToken(user);
        return AuthResponse.builder().token(jwtToken).name(user.getName()).email(user.getEmail()).build();
    }

    // 5. LOGIC XỬ LÝ ĐĂNG NHẬP BẰNG FACEBOOK
    public AuthResponse loginWithFacebook(String facebookToken) {
        Map<String, Object> facebookUserInfo = oAuth2Service.verifyFacebookToken(facebookToken);
        String email = (String) facebookUserInfo.get("email");
        String name = (String) facebookUserInfo.get("name");
        if (email == null) { email = facebookUserInfo.get("id") + "@facebook.com"; }

        User user = processOAuth2User(email, name, Provider.FACEBOOK, true);
        String jwtToken = jwtTokenProvider.generateToken(user);
        return AuthResponse.builder().token(jwtToken).name(user.getName()).email(user.getEmail()).build();
    }

    // 6. LOGIC XỬ LÝ ĐĂNG KÝ BẰNG FACEBOOK
    public AuthResponse registerWithFacebook(String facebookToken) {
        Map<String, Object> facebookUserInfo = oAuth2Service.verifyFacebookToken(facebookToken);
        String email = (String) facebookUserInfo.get("email");
        String name = (String) facebookUserInfo.get("name");
        if (email == null) { email = facebookUserInfo.get("id") + "@facebook.com"; }

        User user = processOAuth2User(email, name, Provider.FACEBOOK, false);
        String jwtToken = jwtTokenProvider.generateToken(user);
        return AuthResponse.builder().token(jwtToken).name(user.getName()).email(user.getEmail()).build();
    }

    // HÀM DÙNG CHUNG: KIỂM TRA ĐĂNG NHẬP / ĐĂNG KÝ USER MẠNG XÃ HỘI
    private User processOAuth2User(String email, String name, Provider provider, boolean isLogin) {
        return userRepository.findFirstByEmail(email)
                .map(existingUser -> {
                    // Nếu tài khoản đã tồn tại nhưng trước đó đăng ký bằng nguồn khác (ví dụ LOCAL)
                    if (!existingUser.getProvider().equals(provider)) {
                        throw new RuntimeException("Email này đã được đăng ký bằng phương thức khác: " + existingUser.getProvider());
                    }
                    if (!isLogin) {
                        throw new RuntimeException("Tài khoản đã tồn tại. Vui lòng đăng nhập!");
                    }
                    return existingUser;
                })
                .orElseGet(() -> {
                    if (isLogin) {
                        throw new RuntimeException("Tài khoản chưa được đăng ký. Vui lòng đăng ký trước!");
                    }
                    // Nếu chưa tồn tại tài khoản và đang thực hiện đăng ký, tạo mới
                    User newUser = User.builder()
                            .name(name)
                            .email(email)
                            .password(null) // Tài khoản mạng xã hội không lưu mật khẩu
                            .provider(provider)
                            .build();
                    return userRepository.save(newUser);
                });
    }
}
