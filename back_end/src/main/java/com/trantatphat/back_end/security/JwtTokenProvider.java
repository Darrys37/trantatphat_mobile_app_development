package com.trantatphat.back_end.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Component
public class JwtTokenProvider {

    // Nạp khóa bí mật từ file application.properties
    @Value("${app.jwt.secret}")
    private String jwtSecret;

    // Nạp thời gian hết hạn token (86400000 ms = 1 ngày)
    @Value("${app.jwt.expiration-ms}")
    private Long jwtExpirationInMs;

    // Hàm tạo ra SecretKey chuẩn thuật toán HMAC từ chuỗi cấu hình dạng text công khai
    private SecretKey getSigningKey() {
        byte[] keyBytes = this.jwtSecret.getBytes(StandardCharsets.UTF_8);
        return Keys.hmacShaKeyFor(keyBytes);
    }

    // 1. HÀM SINH TOKEN JWT DÀNH CHO USER ĐĂNG NHẬP THÀNH CÔNG
    public String generateToken(UserDetails userDetails) {
        Map<String, Object> claims = new HashMap<>();
        return Jwts.builder()
                .claims(claims)
                .subject(userDetails.getUsername()) // Lưu Email của user vào trường 'sub'
                .issuedAt(new Date(System.currentTimeMillis())) // Thời gian phát hành token
                .expiration(new Date(System.currentTimeMillis() + jwtExpirationInMs)) // Thời gian hết hạn
                .signWith(getSigningKey(), Jwts.SIG.HS256) // Ký số bằng thuật toán mã hóa đối xứng HS256
                .compact();
    }

    // 2. HÀM TRÍCH XUẤT EMAIL TỪ CHUỖI JWT GỬI LÊN
    public String extractEmail(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    // Hàm lấy ra một trường thông tin (Claim) cụ thể từ Token
    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    // Giải mã toàn bộ gói dữ liệu bên trong JWT bằng cách dùng SecretKey đối chiếu
    private Claims extractAllClaims(String token) {
        return Jwts.parser()
                .verifyWith(getSigningKey()) // Sử dụng khóa bí mật để xác thực chữ ký số
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    // 3. HÀM KIỂM TRA TÍNH HỢP LỆ VÀ HẠN SỬ DỤNG CỦA TOKEN
    public boolean validateToken(String token, UserDetails userDetails) {
        try {
            final String email = extractEmail(token);
            // Token hợp lệ nếu email trích xuất trùng khớp với email hệ thống và chưa bị hết hạn
            return (email.equals(userDetails.getUsername()) && !isTokenExpired(token));
        } catch (JwtException | IllegalArgumentException e) {
            // Token bị chỉnh sửa cấu trúc hoặc sai chữ ký số sẽ rơi vào đây
            return false;
        }
    }

    // Kiểm tra xem hạn sử dụng của Token đã nhỏ hơn thời gian hiện tại chưa
    private boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    // Trích xuất ngày hết hạn của token
    private Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }
}
