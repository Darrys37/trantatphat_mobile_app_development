package com.example.auth.auth.service;

import com.example.auth.auth.entity.User;
import com.example.auth.dto.request.LoginRequest;
import com.example.auth.dto.request.OAuth2LoginRequest;
import com.example.auth.dto.request.SignupRequest;
import com.example.auth.dto.response.AuthResponse;

public interface AuthService {
    AuthResponse signup(SignupRequest request);
    AuthResponse login(LoginRequest request);
    void logout(String email);
    AuthResponse refreshToken(String refreshToken);
    AuthResponse loginWithOAuth2(OAuth2LoginRequest request, User.AuthProvider provider);
}