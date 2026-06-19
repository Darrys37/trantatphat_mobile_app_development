package com.trantatphat.back_end.controller;

import com.trantatphat.back_end.entity.User;
import com.trantatphat.back_end.payload.request.CartItemRequest;
import com.trantatphat.back_end.payload.response.CartItemResponse;
import com.trantatphat.back_end.repository.UserRepository;
import com.trantatphat.back_end.service.CartService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartService cartService;
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
    public ResponseEntity<List<CartItemResponse>> getCartItems() {
        User user = getAuthenticatedUser();
        List<CartItemResponse> items = cartService.getCartItems(user);
        return ResponseEntity.ok(items);
    }

    @PostMapping("/add")
    public ResponseEntity<CartItemResponse> addToCart(@RequestBody CartItemRequest request) {
        User user = getAuthenticatedUser();
        CartItemResponse response = cartService.addToCart(user, request);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/update/{cartItemId}")
    public ResponseEntity<CartItemResponse> updateQuantity(
            @PathVariable UUID cartItemId, 
            @RequestParam int quantity) {
        User user = getAuthenticatedUser();
        CartItemResponse response = cartService.updateQuantity(user, cartItemId, quantity);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/remove/{cartItemId}")
    public ResponseEntity<?> removeFromCart(@PathVariable UUID cartItemId) {
        User user = getAuthenticatedUser();
        cartService.removeFromCart(user, cartItemId);
        return ResponseEntity.ok().build();
    }
}
