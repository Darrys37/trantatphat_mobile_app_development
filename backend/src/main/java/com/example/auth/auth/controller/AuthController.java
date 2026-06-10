package com.example.auth.auth.controller;

import com.example.auth.auth.entity.User;
import com.example.auth.auth.service.AuthService;
import com.example.auth.dto.request.LoginRequest;
import com.example.auth.dto.request.OAuth2LoginRequest;
import com.example.auth.dto.request.SignupRequest;
import com.example.auth.dto.response.AuthResponse;
import com.example.auth.dto.response.MessageResponse;
import com.example.auth.security.JwtService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {
    
    private final AuthService authService;
    private final JwtService jwtService;
    
    @PostMapping("/signup")
    public ResponseEntity<AuthResponse> signup(@Valid @RequestBody SignupRequest request) {
        return ResponseEntity.ok(authService.signup(request));
    }
    
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }
    
    @PostMapping("/logout")
    public ResponseEntity<MessageResponse> logout(
            @RequestHeader(value = "Authorization", required = false) String authHeader) {
        
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            String email = jwtService.extractUsername(token);
            authService.logout(email);
        }
        
        return ResponseEntity.ok(MessageResponse.builder()
                .message("Logged out successfully")
                .success(true)
                .build());
    }
    
    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refreshToken(@RequestBody Map<String, String> request) {
        String refreshToken = request.get("refreshToken");
        return ResponseEntity.ok(authService.refreshToken(refreshToken));
    }
    
    // Health check
    @GetMapping("/health")
    public ResponseEntity<MessageResponse> health() {
        return ResponseEntity.ok(MessageResponse.builder()
                .message("Auth service is running")
                .success(true)
                .build());
    }
    @PostMapping("/oauth2/google")
public ResponseEntity<AuthResponse> loginWithGoogle(@RequestBody OAuth2LoginRequest request) {
    return ResponseEntity.ok(authService.loginWithOAuth2(
        request, User.AuthProvider.GOOGLE
    ));
}

@PostMapping("/oauth2/facebook")
public ResponseEntity<AuthResponse> loginWithFacebook(@RequestBody OAuth2LoginRequest request) {
    return ResponseEntity.ok(authService.loginWithOAuth2(
        request, User.AuthProvider.FACEBOOK
    ));
}
}