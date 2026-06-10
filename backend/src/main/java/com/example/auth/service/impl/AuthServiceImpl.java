package com.example.auth.service.impl;

import com.example.auth.entity.Role;
import com.example.auth.entity.User;
import com.example.auth.repository.RoleRepository;
import com.example.auth.repository.UserRepository;
import com.example.auth.service.AuthResponse;
import com.example.auth.service.AuthService;
import com.example.auth.service.LoginRequest;
import com.example.auth.service.OAuth2LoginRequest;
import com.example.auth.service.SignupRequest;
import com.example.auth.service.UserProfileResponse;
import com.example.auth.config.exception.BadRequestException;
import com.example.auth.config.exception.ResourceNotFoundException;
import com.example.auth.security.JwtService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    @Value("${jwt.expiration}")
    private Long jwtExpiration;

    private static final String DEFAULT_ROLE = "ROLE_USER";
    private static final String TOKEN_TYPE   = "Bearer";

    @Override
    @Transactional
    public AuthResponse signup(SignupRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            log.warn("Signup attempt with existing email: {}", request.getEmail());
            throw new BadRequestException("Email đã tồn tại trong hệ thống");
        }

        Role userRole = roleRepository.findByName(DEFAULT_ROLE)
                .orElseThrow(() -> new RuntimeException("Lỗi hệ thống: Không tìm thấy ROLE_USER."));

        Set<Role> roles = new HashSet<>();
        roles.add(userRole);

        User user = User.builder()
                .fullName(request.getFullName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .provider(User.AuthProvider.LOCAL)
                .createdAt(LocalDateTime.now())
                .roles(roles)
                .build();

        userRepository.save(user);
        log.info("User registered successfully: {}", user.getEmail());
        return buildAuthResponse(user);
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getEmail(),
                            request.getPassword()
                    )
            );
        } catch (AuthenticationException e) {
            log.warn("Login failed for email: {} - Reason: {}", request.getEmail(), e.getMessage());
            throw e;
        }

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        log.info("User logged in successfully: {}", user.getEmail());
        return buildAuthResponse(user);
    }

    @Override
    public void logout(String email) {
        log.info("User logged out: {}", email);
    }

    @Override
    @Transactional(readOnly = true)
    public AuthResponse refreshToken(String refreshToken) {
        String email;
        try {
            email = jwtService.extractUsername(refreshToken);
        } catch (Exception e) {
            throw new BadRequestException("Định dạng Refresh Token không hợp lệ");
        }

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User", "email", email));

        if (!jwtService.isTokenValid(refreshToken, user)) {
            throw new BadRequestException("Refresh Token đã hết hạn hoặc không hợp lệ");
        }

        log.info("Token refreshed for user: {}", email);
        return buildAuthResponse(user);
    }

    @Override
    @Transactional
    public AuthResponse loginWithOAuth2(OAuth2LoginRequest request, User.AuthProvider provider) {
        User user = userRepository.findByEmail(request.getEmail())
            .orElseGet(() -> {
                Role userRole = roleRepository.findByName("ROLE_USER")
                    .orElseThrow(() -> new RuntimeException("Lỗi hệ thống: Không tìm thấy ROLE_USER"));

                Set<Role> roles = new HashSet<>();
                roles.add(userRole);

                User newUser = User.builder()
                    .email(request.getEmail())
                    .fullName(request.getFullName())
                    .provider(provider)
                    .providerId(request.getProviderId())
                    .createdAt(LocalDateTime.now())
                    .roles(roles)
                    .build();

                return userRepository.save(newUser);
            });

        return buildAuthResponse(user);
    }

    private AuthResponse buildAuthResponse(User user) {
        String accessToken  = jwtService.generateToken(user);
        String refreshToken = jwtService.generateRefreshToken(user);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType(TOKEN_TYPE)
                .expiresIn(jwtExpiration)
                .user(UserProfileResponse.fromEntity(user))
                .build();
    }
}
