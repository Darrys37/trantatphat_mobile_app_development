package com.trantatphat.back_end.controller;

import com.trantatphat.back_end.entity.Product;
import com.trantatphat.back_end.entity.User;
import com.trantatphat.back_end.repository.UserRepository;
import com.trantatphat.back_end.service.FavoriteService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/favorites")
@RequiredArgsConstructor
public class FavoriteController {

    private final FavoriteService favoriteService;
    private final UserRepository userRepository;

    private User getAuthenticatedUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated() || "anonymousUser".equals(authentication.getPrincipal())) {
            throw new RuntimeException("User not authenticated");
        }
        String email = authentication.getName();
        return userRepository.findFirstByEmail(email).orElseThrow(() -> new RuntimeException("User not found"));
    }

    @GetMapping
    public ResponseEntity<List<Product>> getUserFavorites() {
        User user = getAuthenticatedUser();
        List<Product> favorites = favoriteService.getUserFavorites(user);
        return ResponseEntity.ok(favorites);
    }

    @PostMapping("/{productId}")
    public ResponseEntity<?> addFavorite(@PathVariable UUID productId) {
        User user = getAuthenticatedUser();
        favoriteService.addFavorite(user, productId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{productId}")
    public ResponseEntity<?> removeFavorite(@PathVariable UUID productId) {
        User user = getAuthenticatedUser();
        favoriteService.removeFavorite(user, productId);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/check/{productId}")
    public ResponseEntity<Boolean> isFavorited(@PathVariable UUID productId) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated() || "anonymousUser".equals(authentication.getPrincipal())) {
            return ResponseEntity.ok(false);
        }
        
        String email = authentication.getName();
        User user = userRepository.findFirstByEmail(email).orElse(null);
        if (user == null) {
            return ResponseEntity.ok(false);
        }

        boolean isFavorited = favoriteService.isFavorited(user, productId);
        return ResponseEntity.ok(isFavorited);
    }
}
