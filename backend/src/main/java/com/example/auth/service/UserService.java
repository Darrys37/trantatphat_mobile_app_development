package com.example.auth.service;

import com.example.auth.entity.User;

public interface UserService {
    User getCurrentUser(String email);
    UserProfileResponse getUserProfile(String email);
    UserProfileResponse updateUserProfile(String email, String fullName);
    void deleteUser(String email);
}
