package com.trantatphat.back_end.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**") // Áp dụng cấu hình CORS cho TẤT CẢ các đường dẫn API trong hệ thống
                .allowedOrigins("*") // Cho phép TẤT CẢ các thiết bị (bao gồm điện thoại của bạn) gọi API
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS") // Cho phép các phương thức gửi nhận dữ liệu
                .allowedHeaders("*") // Cho phép gửi kèm tất cả các loại Header (bao gồm cả Header chứa JWT)
                .exposedHeaders("Authorization") // Cho phép Flutter đọc được trường Authorization nếu cần
                .maxAge(3600); // Thử nghiệm CORS trước trong vòng 1 tiếng để tăng tốc độ phản hồi request
    }
}
