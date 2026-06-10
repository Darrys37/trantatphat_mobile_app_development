package com.example.auth.security;

import com.example.auth.entity.Role;
import com.example.auth.entity.User;
import com.example.auth.repository.RoleRepository;
import com.example.auth.repository.UserRepository;
import com.example.auth.service.AuthResponse;
import com.example.auth.service.UserProfileResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Component
@RequiredArgsConstructor
@Slf4j
public class OAuth2SuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

    private final JwtService jwtService;
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final ObjectMapper objectMapper;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                        Authentication authentication) throws IOException, ServletException {

        OAuth2AuthenticationToken oauthToken   = (OAuth2AuthenticationToken) authentication;
        OAuth2User oAuth2User                  = oauthToken.getPrincipal();
        String registrationId                  = oauthToken.getAuthorizedClientRegistrationId();

        String sub = oAuth2User.getAttribute("sub");
        String id  = oAuth2User.getAttribute("id");
        final String providerId = (sub != null) ? sub : id;

        String rawEmail = oAuth2User.getAttribute("email");
        final String email = (rawEmail != null) ? rawEmail : (providerId + "@" + registrationId + ".com");
        final String name  = oAuth2User.getAttribute("name");

        User user = userRepository.findByEmail(email).orElseGet(() -> {
            log.info("Creating new OAuth2 user: {}", email);

            Role userRole = roleRepository.findByName("ROLE_USER").orElseGet(() -> {
                Role newRole = Role.builder().name("ROLE_USER").build();
                return roleRepository.save(newRole);
            });

            Set<Role> roles = new HashSet<>();
            roles.add(userRole);

            User.AuthProvider provider = registrationId.equalsIgnoreCase("google")
                    ? User.AuthProvider.GOOGLE
                    : User.AuthProvider.FACEBOOK;

            return userRepository.save(User.builder()
                    .email(email)
                    .fullName(name != null ? name : "OAuth2 User")
                    .provider(provider)
                    .providerId(providerId)
                    .roles(roles)
                    .createdAt(LocalDateTime.now())
                    .build());
        });

        String accessToken  = jwtService.generateToken(user);
        String refreshToken = jwtService.generateRefreshToken(user);

        AuthResponse authResponse = AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(86400000L)
                .user(UserProfileResponse.fromEntity(user))
                .build();

        String referer = request.getHeader("Referer");
        if (referer != null && (referer.contains("localhost:3000") || referer.contains("127.0.0.1:3000"))) {
            String redirectUrl = String.format(
                "http://localhost:3000/#/auth/callback?access_token=%s&refresh_token=%s",
                accessToken, refreshToken);
            getRedirectStrategy().sendRedirect(request, response, redirectUrl);
        } else {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            objectMapper.writeValue(response.getOutputStream(), authResponse);
        }
    }
}
