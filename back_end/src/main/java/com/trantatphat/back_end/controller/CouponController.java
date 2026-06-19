package com.trantatphat.back_end.controller;

import com.trantatphat.back_end.entity.Cart;
import com.trantatphat.back_end.entity.User;
import com.trantatphat.back_end.payload.response.CouponResponse;
import com.trantatphat.back_end.repository.UserRepository;
import com.trantatphat.back_end.service.CartService;
import com.trantatphat.back_end.service.CouponService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/coupons")
@RequiredArgsConstructor
public class CouponController {

    private final CouponService couponService;
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
    public ResponseEntity<List<CouponResponse>> getActiveCoupons() {
        return ResponseEntity.ok(couponService.getActiveCoupons());
    }

    @GetMapping("/applied")
    public ResponseEntity<CouponResponse> getAppliedCoupon() {
        User user = getAuthenticatedUser();
        Cart cart = cartService.getOrCreateCart(user);
        if (cart.getCoupon() != null) {
            return ResponseEntity.ok(couponService.mapToResponse(cart.getCoupon()));
        }
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/apply")
    public ResponseEntity<?> applyCoupon(@RequestParam String code) {
        User user = getAuthenticatedUser();
        couponService.applyCoupon(user, code);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/remove")
    public ResponseEntity<?> removeCoupon() {
        User user = getAuthenticatedUser();
        couponService.removeCoupon(user);
        return ResponseEntity.ok().build();
    }
}
