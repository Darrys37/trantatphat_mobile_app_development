package com.trantatphat.back_end.controller;

import com.trantatphat.back_end.entity.DeliveryMethod;
import com.trantatphat.back_end.entity.PaymentCard;
import com.trantatphat.back_end.entity.User;
import com.trantatphat.back_end.entity.UserAddress;
import com.trantatphat.back_end.repository.UserRepository;
import com.trantatphat.back_end.service.CheckoutService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.DeleteMapping;

import com.trantatphat.back_end.dto.SubmitOrderRequest;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/checkout")
@RequiredArgsConstructor
public class CheckoutController {

    private final CheckoutService checkoutService;
    private final UserRepository userRepository;

    private User getAuthenticatedUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated() || "anonymousUser".equals(authentication.getPrincipal())) {
            throw new RuntimeException("User not authenticated");
        }
        String email = authentication.getName();
        return userRepository.findFirstByEmail(email).orElseThrow(() -> new RuntimeException("User not found"));
    }

    @GetMapping("/addresses")
    public ResponseEntity<List<UserAddress>> getAddresses() {
        return ResponseEntity.ok(checkoutService.getUserAddresses(getAuthenticatedUser()));
    }

    @GetMapping("/payment-cards")
    public ResponseEntity<List<PaymentCard>> getPaymentCards() {
        return ResponseEntity.ok(checkoutService.getPaymentCards(getAuthenticatedUser()));
    }

    @GetMapping("/delivery-methods")
    public ResponseEntity<List<DeliveryMethod>> getDeliveryMethods() {
        return ResponseEntity.ok(checkoutService.getDeliveryMethods());
    }

    @PostMapping("/payment-cards")
    public ResponseEntity<PaymentCard> addPaymentCard(@RequestBody PaymentCard card) {
        return ResponseEntity.ok(checkoutService.addPaymentCard(getAuthenticatedUser(), card));
    }

    @PutMapping("/payment-cards/{id}/default")
    public ResponseEntity<?> setDefaultPaymentCard(@PathVariable UUID id) {
        checkoutService.setDefaultPaymentCard(getAuthenticatedUser(), id);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/payment-cards/{id}")
    public ResponseEntity<?> deletePaymentCard(@PathVariable UUID id) {
        checkoutService.deletePaymentCard(getAuthenticatedUser(), id);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/addresses")
    public ResponseEntity<UserAddress> addAddress(@RequestBody UserAddress address) {
        return ResponseEntity.ok(checkoutService.addUserAddress(getAuthenticatedUser(), address));
    }

    @PutMapping("/addresses/{id}")
    public ResponseEntity<UserAddress> updateAddress(@PathVariable UUID id, @RequestBody UserAddress address) {
        return ResponseEntity.ok(checkoutService.updateUserAddress(getAuthenticatedUser(), id, address));
    }

    @PutMapping("/addresses/{id}/default")
    public ResponseEntity<?> setDefaultAddress(@PathVariable UUID id) {
        checkoutService.setDefaultUserAddress(getAuthenticatedUser(), id);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/addresses/{id}")
    public ResponseEntity<?> deleteAddress(@PathVariable UUID id) {
        checkoutService.deleteUserAddress(getAuthenticatedUser(), id);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/submit-order")
    public ResponseEntity<?> submitOrder(@RequestBody SubmitOrderRequest request) {
        checkoutService.submitOrder(getAuthenticatedUser(), request);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/orders")
    public ResponseEntity<List<com.trantatphat.back_end.dto.OrderDto>> getUserOrders() {
        return ResponseEntity.ok(checkoutService.getUserOrders(getAuthenticatedUser()));
    }

    @GetMapping("/orders/{id}")
    public ResponseEntity<com.trantatphat.back_end.dto.OrderDetailsDto> getOrderDetails(@PathVariable String id) {
        return ResponseEntity.ok(checkoutService.getOrderDetails(getAuthenticatedUser(), id));
    }

    @PutMapping("/orders/{id}/cancel")
    public ResponseEntity<?> cancelOrder(@PathVariable String id) {
        checkoutService.cancelOrder(getAuthenticatedUser(), id);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/clear-processing")
    public ResponseEntity<?> clearProcessingOrders() {
        checkoutService.clearProcessingOrders();
        return ResponseEntity.ok().build();
    }
}
