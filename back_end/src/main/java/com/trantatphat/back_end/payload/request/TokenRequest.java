package com.trantatphat.back_end.payload.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data // Tự động sinh Getter, Setter, toString...
@NoArgsConstructor // Tạo Constructor không tham số để Jackson giải mã JSON
@AllArgsConstructor // Tạo Constructor đầy đủ tham số
public class TokenRequest {
    
    private String token;
}
