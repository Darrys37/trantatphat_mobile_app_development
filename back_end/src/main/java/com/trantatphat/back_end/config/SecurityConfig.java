package com.trantatphat.back_end.config;

import com.trantatphat.back_end.security.JwtAuthenticationFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    // Bộ lọc JWT để kiểm tra token từ điện thoại gửi lên từng request
    private final JwtAuthenticationFilter jwtAuthFilter;
    
    // Nơi chứa cấu hình mã hóa password và tìm kiếm user trong DB
    private final AuthenticationProvider authenticationProvider;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            // 1. Tắt CSRF vì hệ thống sử dụng Stateless JWT (không dùng Cookie/Session)
            .csrf(AbstractHttpConfigurer::disable)
            
            // 2. Cấu hình phân quyền các đường dẫn API
            .authorizeHttpRequests(auth -> auth
                // Cho phép tất cả mọi người truy cập vào các API Auth (Đăng nhập, đăng ký) và API Sản phẩm
                .requestMatchers("/api/auth/**", "/api/products/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/reviews/**").permitAll()

                // Mở khóa cho phương thức OPTIONS (Rất quan trọng để Flutter chạy không bị lỗi CORS)
                .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                
                // Tất cả các API còn lại (Ví dụ: lấy thông tin user, mua hàng...) đều bắt buộc phải đăng nhập
                .anyRequest().authenticated()
            )
            
            // 3. Cấu hình Quản lý Session là STATELESS (Không lưu trạng thái phiên đăng nhập trên Server)
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            
            // 4. Nạp cấu hình Authentication Provider (Quản lý xác thực dữ liệu)
            .authenticationProvider(authenticationProvider)
            
            // 5. Thêm bộ lọc JWT chạy TRƯỚC bộ lọc xác thực mặc định của Spring Security
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
