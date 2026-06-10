package com.example.auth.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OAuth2LoginRequest {
    
    @NotBlank(message = "Provider is required")
    private String provider;  // GOOGLE, FACEBOOK
    
    @NotBlank(message = "Access token is required")
    private String accessToken;
    
    private String providerId;
    private String email;
    private String fullName;
    private String avatar;
}