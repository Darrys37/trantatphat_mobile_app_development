package com.trantatphat.back_end.controller;

import com.trantatphat.back_end.payload.request.LoginRequest;
import com.trantatphat.back_end.payload.request.RegisterRequest;
import com.trantatphat.back_end.payload.request.TokenRequest;
import com.trantatphat.back_end.payload.response.AuthResponse;
import com.trantatphat.back_end.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    // 1. API Đăng ký bằng Email & Password truyền thống
    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestBody RegisterRequest request) {
        String result = authService.register(request);
        return ResponseEntity.ok(result);
    }

    // 2. API Đăng nhập bằng Email & Password truyền thống -> Trả về mã JWT
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    // 3. API Đăng nhập bằng Tài khoản Google (OAuth2)
    @PostMapping("/google/login")
    public ResponseEntity<?> loginWithGoogle(@RequestBody TokenRequest request) {
        try {
            AuthResponse response = authService.loginWithGoogle(request.getToken());
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // 4. API Đăng ký bằng Tài khoản Google (OAuth2)
    @PostMapping("/google/register")
    public ResponseEntity<?> registerWithGoogle(@RequestBody TokenRequest request) {
        try {
            AuthResponse response = authService.registerWithGoogle(request.getToken());
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // 5. API Đăng nhập bằng Tài khoản Facebook (OAuth2)
    @PostMapping("/facebook/login")
    public ResponseEntity<?> loginWithFacebook(@RequestBody TokenRequest request) {
        try {
            AuthResponse response = authService.loginWithFacebook(request.getToken());
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // 6. API Đăng ký bằng Tài khoản Facebook (OAuth2)
    @PostMapping("/facebook/register")
    public ResponseEntity<?> registerWithFacebook(@RequestBody TokenRequest request) {
        try {
            AuthResponse response = authService.registerWithFacebook(request.getToken());
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
