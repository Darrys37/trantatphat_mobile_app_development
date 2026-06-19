package com.trantatphat.back_end.payload.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data // Tự động sinh các hàm Getter, Setter, toString, equals, hashCode
@NoArgsConstructor // Tự động tạo Constructor không có tham số (bắt buộc cho việc mapping JSON)
@AllArgsConstructor // Tự động tạo Constructor có đầy đủ tham số (email, password)
public class LoginRequest {
    
    private String email;
    private String password;
}
