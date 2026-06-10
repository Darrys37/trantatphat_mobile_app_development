package com.example.auth.user.controller;

import com.example.auth.auth.service.UserService;
import com.example.auth.dto.response.MessageResponse;
import com.example.auth.dto.response.UserProfileResponse;
import com.example.auth.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/user")
@RequiredArgsConstructor
public class UserController {
    
    private final UserService userService;
    private final JwtService jwtService;
    
    // Lấy profile của user đang login
    @GetMapping("/profile")
    public ResponseEntity<UserProfileResponse> getProfile(
            @RequestHeader("Authorization") String authHeader) {
        
        String email = extractEmailFromToken(authHeader);
        return ResponseEntity.ok(userService.getUserProfile(email));
    }
    
    // Cập nhật profile
    @PutMapping("/profile")
    public ResponseEntity<UserProfileResponse> updateProfile(
            @RequestHeader("Authorization") String authHeader,
            @RequestBody Map<String, String> request) {
        
        String email = extractEmailFromToken(authHeader);
        String fullName = request.get("fullName");
        
        return ResponseEntity.ok(userService.updateUserProfile(email, fullName));
    }
    
    // Chỉ ADMIN mới xem được danh sách user (ví dụ phân quyền)
    @GetMapping("/admin/users")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<MessageResponse> adminEndpoint() {
        return ResponseEntity.ok(MessageResponse.builder()
                .message("Welcome Admin!")
                .success(true)
                .build());
    }
    
    // Helper method: lấy email từ JWT token
    private String extractEmailFromToken(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            throw new RuntimeException("Invalid authorization header");
        }
        String token = authHeader.substring(7);
        return jwtService.extractUsername(token);
    }
}