package com.example.auth.auth.service;

import com.example.auth.auth.entity.User;
import com.example.auth.dto.response.UserProfileResponse;

public interface UserService {
    
    User getCurrentUser(String email);
    
    UserProfileResponse getUserProfile(String email);
    
    UserProfileResponse updateUserProfile(String email, String fullName);
    
    void deleteUser(String email);
}