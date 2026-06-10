package com.example.auth.service;

import com.example.auth.entity.User;

public interface AuthService {
    AuthResponse signup(SignupRequest request);
    AuthResponse login(LoginRequest request);
    void logout(String email);
    AuthResponse refreshToken(String refreshToken);
    AuthResponse loginWithOAuth2(OAuth2LoginRequest request, User.AuthProvider provider);
}
