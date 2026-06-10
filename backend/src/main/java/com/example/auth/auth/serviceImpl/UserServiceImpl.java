package com.example.auth.auth.serviceImpl;

import com.example.auth.auth.entity.User;
import com.example.auth.auth.repository.UserRepository;
import com.example.auth.auth.service.UserService;
import com.example.auth.dto.response.UserProfileResponse;
import com.example.auth.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    
    private final UserRepository userRepository;
    
    @Override
    public User getCurrentUser(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "User", "email", email
                ));
    }
    
    @Override
    public UserProfileResponse getUserProfile(String email) {
        User user = getCurrentUser(email);
        return UserProfileResponse.fromEntity(user);
    }
    
    @Override
    @Transactional
    public UserProfileResponse updateUserProfile(String email, String fullName) {
        User user = getCurrentUser(email);
        user.setFullName(fullName);
        User updatedUser = userRepository.save(user);
        return UserProfileResponse.fromEntity(updatedUser);
    }
    
    @Override
    @Transactional
    public void deleteUser(String email) {
        User user = getCurrentUser(email);
        userRepository.delete(user);
    }
}