package com.trantatphat.back_end.payload.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data // Tự động sinh các hàm Getter, Setter, toString, equals, hashCode
@NoArgsConstructor // Tự động tạo Constructor không tham số (Bắt buộc để Spring giải mã JSON)
@AllArgsConstructor // Tự động tạo Constructor đầy đủ tham số (name, email, password)
public class RegisterRequest {

    private String name;
    private String email;
    private String password;
}
