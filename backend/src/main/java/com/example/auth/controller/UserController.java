package com.example.auth.controller;

import com.example.auth.service.UserProfileResponse;
import com.example.auth.service.UserService;
import com.example.auth.config.exception.MessageResponse;
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

    @GetMapping("/profile")
    public ResponseEntity<UserProfileResponse> getProfile(
            @RequestHeader("Authorization") String authHeader) {
        return ResponseEntity.ok(userService.getUserProfile(extractEmail(authHeader)));
    }

    @PutMapping("/profile")
    public ResponseEntity<UserProfileResponse> updateProfile(
            @RequestHeader("Authorization") String authHeader,
            @RequestBody Map<String, String> request) {
        return ResponseEntity.ok(
                userService.updateUserProfile(extractEmail(authHeader), request.get("fullName")));
    }

    @GetMapping("/admin/users")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<MessageResponse> adminEndpoint() {
        return ResponseEntity.ok(MessageResponse.builder()
                .message("Welcome Admin!")
                .success(true)
                .build());
    }

    private String extractEmail(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            throw new RuntimeException("Invalid authorization header");
        }
        return jwtService.extractUsername(authHeader.substring(7));
    }
}
