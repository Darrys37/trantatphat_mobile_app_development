package com.example.auth.auth.serviceImpl;

import com.example.auth.auth.entity.Role;
import com.example.auth.auth.entity.User;
import com.example.auth.auth.repository.RoleRepository;
import com.example.auth.auth.repository.UserRepository;
import com.example.auth.auth.service.AuthService;
import com.example.auth.dto.request.LoginRequest;
import com.example.auth.dto.request.OAuth2LoginRequest;
import com.example.auth.dto.request.SignupRequest;
import com.example.auth.dto.response.AuthResponse;
import com.example.auth.dto.response.UserProfileResponse;
import com.example.auth.exception.BadRequestException;
import com.example.auth.exception.ResourceNotFoundException;
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
@Slf4j // ⭐ Tự động tạo biến 'log' để ghi log
public class AuthServiceImpl implements AuthService {
    
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    
    // ⭐ Lấy thời gian expire từ application.yml thay vì hardcode
    @Value("${jwt.expiration}")
    private Long jwtExpiration;

    private static final String DEFAULT_ROLE = "ROLE_USER";
    private static final String TOKEN_TYPE = "Bearer";
    
    @Override
    @Transactional // ⭐ Đảm bảo nếu có lỗi khi save User, transaction sẽ rollback
    public AuthResponse signup(SignupRequest request) {
        // 1. Kiểm tra email đã tồn tại chưa
        if (userRepository.existsByEmail(request.getEmail())) {
            log.warn("Signup attempt with existing email: {}", request.getEmail());
            throw new BadRequestException("Email đã tồn tại trong hệ thống");
        }
        
        // 2. Tìm Role mặc định
        Role userRole = roleRepository.findByName(DEFAULT_ROLE)
                .orElseThrow(() -> new RuntimeException("Lỗi hệ thống: Không tìm thấy ROLE_USER. Hãy kiểm tra DataInitializer."));
        
        Set<Role> roles = new HashSet<>();
        roles.add(userRole);
        
        // 3. Tạo User mới
        User user = User.builder()
                .fullName(request.getFullName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword())) // Mã hóa BCrypt
                .provider(User.AuthProvider.LOCAL)
                .createdAt(LocalDateTime.now())
                .roles(roles)
                .build();
        
        userRepository.save(user);
        log.info("User registered successfully: {}", user.getEmail());
        
        // 4. Tạo Token và Response
        return buildAuthResponse(user);
    }
    
    @Override
    public AuthResponse login(LoginRequest request) {
        // 1. Xác thực Email/Password qua Spring Security
        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getEmail(),
                            request.getPassword()
                    )
            );
        } catch (AuthenticationException e) {
            log.warn("Login failed for email: {} - Reason: {}", request.getEmail(), e.getMessage());
            throw e; // Ném ra để GlobalExceptionHandler tự động trả về lỗi 401 Unauthorized
        }
        
        // 2. Tìm User trong DB
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));
        
        log.info("User logged in successfully: {}", user.getEmail());
        
        // 3. Tạo Token và Response
        return buildAuthResponse(user);
    }
    
    @Override
    public void logout(String email) {
        /* 
         * 💡 LƯU Ý KIẾN TRÚC:
         * JWT là Stateless (không lưu session trên server). 
         * Việc logout thực chất là Frontend tự xóa Token khỏi bộ nhớ.
         * Nếu muốn chặn Token cũ ngay lập tức, bạn cần dùng Redis để Blacklist Token này.
         */
        log.info("User logged out: {}", email);
    }
    
    @Override
    @Transactional(readOnly = true) // ⭐ Tối ưu hiệu suất vì chỉ đọc DB, không ghi
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

    // ==========================================
    // ⭐ HELPER METHOD (Hàm dùng chung để giảm lặp code)
    // ==========================================
    private AuthResponse buildAuthResponse(User user) {
        String accessToken = jwtService.generateToken(user);
        String refreshToken = jwtService.generateRefreshToken(user);
        
        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType(TOKEN_TYPE)
                .expiresIn(jwtExpiration) // Dùng biến lấy từ application.yml
                .user(UserProfileResponse.fromEntity(user))
                .build();
    }
        @Override
    @Transactional
    public AuthResponse loginWithOAuth2(OAuth2LoginRequest request, User.AuthProvider provider) {
        // 1. Tìm user theo email, nếu chưa có thì tạo mới (Auto Signup)
        User user = userRepository.findByEmail(request.getEmail())
            .orElseGet(() -> {
                // 2. Lấy Role mặc định
                Role userRole = roleRepository.findByName("ROLE_USER")
                    .orElseThrow(() -> new RuntimeException("Lỗi hệ thống: Không tìm thấy ROLE_USER"));
                
                // 3. Tạo Set chứa Role (Dùng HashSet để tương thích tốt nhất với JPA/Hibernate)
                java.util.Set<Role> roles = new java.util.HashSet<>();
                roles.add(userRole);
                
                // 4. Build User mới từ thông tin Google/Facebook gửi lên
                User newUser = User.builder()
                    .email(request.getEmail())
                    .fullName(request.getFullName())
                    .provider(provider) // GOOGLE hoặc FACEBOOK
                    .providerId(request.getProviderId())
                    .createdAt(LocalDateTime.now())
                    .roles(roles)
                    .build();
                    
                // 5. Lưu xuống Database
                return userRepository.save(newUser);
            });
        
        // 6. Tạo JWT Token và trả về Response (Tái sử dụng hàm helper đã viết ở trên)
        return buildAuthResponse(user);
    }
}