package com.example.auth.service.impl;

import com.example.auth.entity.User;
import com.example.auth.repository.UserRepository;
import com.example.auth.service.UserProfileResponse;
import com.example.auth.service.UserService;
import com.example.auth.config.exception.ResourceNotFoundException;
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
                .orElseThrow(() -> new ResourceNotFoundException("User", "email", email));
    }

    @Override
    public UserProfileResponse getUserProfile(String email) {
        return UserProfileResponse.fromEntity(getCurrentUser(email));
    }

    @Override
    @Transactional
    public UserProfileResponse updateUserProfile(String email, String fullName) {
        User user = getCurrentUser(email);
        user.setFullName(fullName);
        return UserProfileResponse.fromEntity(userRepository.save(user));
    }

    @Override
    @Transactional
    public void deleteUser(String email) {
        userRepository.delete(getCurrentUser(email));
    }
}
