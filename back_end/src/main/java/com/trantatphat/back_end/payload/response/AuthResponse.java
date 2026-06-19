package com.trantatphat.back_end.payload.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data // Tự động sinh các hàm Getter, Setter, toString...
@Builder // Kích hoạt Design Pattern Builder giúp khởi tạo Object nhanh và linh hoạt
@NoArgsConstructor // Khởi tạo Constructor không tham số (Bắt buộc để Jackson tuần tự hóa JSON)
@AllArgsConstructor // Khởi tạo Constructor đầy đủ tham số
public class AuthResponse {

    private String token; // Chuỗi mã JWT hệ thống cấp cho người dùng
    
    @Builder.Default
    private String tokenType = "Bearer"; // Loại token chuẩn quốc tế (mặc định là Bearer)
    
    private String name; // Tên hiển thị của người dùng (ví dụ: Mr. Muffin)
    private String email; // Email của người dùng
}
