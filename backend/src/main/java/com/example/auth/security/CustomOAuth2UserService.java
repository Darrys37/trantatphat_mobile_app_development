package com.example.auth.security;

import com.example.auth.entity.Role;
import com.example.auth.entity.User;
import com.example.auth.repository.RoleRepository;
import com.example.auth.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class CustomOAuth2UserService extends DefaultOAuth2UserService {
    
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    
    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(userRequest);
        
        String registrationId = userRequest.getClientRegistration().getRegistrationId();
        User.AuthProvider provider = getProvider(registrationId);
        
        Map<String, Object> attributes = oAuth2User.getAttributes();
        String email = getEmail(attributes, provider);
        String name = getName(attributes, provider);
        String providerId = getProviderId(attributes, provider);
        
        User user = userRepository.findByEmail(email)
                .orElseGet(() -> createNewUser(email, name, provider, providerId));
        
        return oAuth2User;
    }
    
    private User createNewUser(String email, String name, User.AuthProvider provider, String providerId) {
        User user = User.builder()
                .email(email)
                .fullName(name)
                .provider(provider)
                .providerId(providerId)
                .createdAt(LocalDateTime.now())
                .roles(new HashSet<>())
                .build();
        
        Role userRole = roleRepository.findByName("ROLE_USER")
                .orElseThrow(() -> new RuntimeException("Role not found"));
        user.getRoles().add(userRole);
        
        return userRepository.save(user);
    }
    
    private User.AuthProvider getProvider(String registrationId) {
        return switch (registrationId.toLowerCase()) {
            case "google" -> User.AuthProvider.GOOGLE;
            case "facebook" -> User.AuthProvider.FACEBOOK;
            default -> throw new IllegalArgumentException("Unknown provider: " + registrationId);
        };
    }
    
    private String getEmail(Map<String, Object> attributes, User.AuthProvider provider) {
        return switch (provider) {
            case GOOGLE -> (String) attributes.get("email");
            case FACEBOOK -> {
                Map<String, Object> emailMap = (Map<String, Object>) attributes.get("email");
                yield emailMap != null ? (String) emailMap.get("value") : null;
            }
            default -> null;
        };
    }
    
    private String getName(Map<String, Object> attributes, User.AuthProvider provider) {
        return switch (provider) {
            case GOOGLE -> (String) attributes.get("name");
            case FACEBOOK -> (String) attributes.get("name");
            default -> "Unknown";
        };
    }
    
    private String getProviderId(Map<String, Object> attributes, User.AuthProvider provider) {
        return switch (provider) {
            case GOOGLE -> (String) attributes.get("sub");
            case FACEBOOK -> (String) attributes.get("id");
            default -> null;
        };
    }
}