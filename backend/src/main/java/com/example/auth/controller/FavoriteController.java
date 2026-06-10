package com.example.auth.controller;

import com.example.auth.entity.Customer;
import com.example.auth.entity.Favorite;
import com.example.auth.entity.Product;
import com.example.auth.repository.CustomerRepository;
import com.example.auth.repository.FavoriteRepository;
import com.example.auth.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/shop/favorites")
@RequiredArgsConstructor
@CrossOrigin
public class FavoriteController {

    private final FavoriteRepository favoriteRepository;
    private final CustomerRepository customerRepository;
    private final ProductRepository productRepository;

    @GetMapping("/{customerId}")
    public ResponseEntity<List<FavoriteResponse>> getFavorites(@PathVariable UUID customerId) {
        List<FavoriteResponse> result = favoriteRepository
                .findByCustomerIdWithProduct(customerId)
                .stream()
                .map(FavoriteResponse::new)
                .collect(Collectors.toList());
        return ResponseEntity.ok(result);
    }

    @PostMapping("/{customerId}/{productId}")
    public ResponseEntity<?> addFavorite(
            @PathVariable UUID customerId,
            @PathVariable UUID productId,
            @RequestBody(required = false) AddFavoriteRequest req) {

        if (favoriteRepository.existsByCustomerIdAndProductId(customerId, productId)) {
            return ResponseEntity.badRequest().body("Already in favorites");
        }

        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new RuntimeException("Customer not found"));
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));

        Favorite fav = Favorite.builder()
                .customer(customer)
                .product(product)
                .selected_size(req != null ? req.getSelected_size() : null)
                .selected_color(req != null ? req.getSelected_color() : null)
                .build();

        return ResponseEntity.ok(new FavoriteResponse(favoriteRepository.save(fav)));
    }

    @PutMapping("/{customerId}/{productId}")
    public ResponseEntity<?> updateFavorite(
            @PathVariable UUID customerId,
            @PathVariable UUID productId,
            @RequestBody AddFavoriteRequest req) {

        return favoriteRepository.findByCustomerIdAndProductId(customerId, productId)
                .map(fav -> {
                    if (req.getSelected_size() != null)  fav.setSelected_size(req.getSelected_size());
                    if (req.getSelected_color() != null) fav.setSelected_color(req.getSelected_color());
                    return ResponseEntity.ok(new FavoriteResponse(favoriteRepository.save(fav)));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{customerId}/{productId}")
    public ResponseEntity<?> removeFavorite(
            @PathVariable UUID customerId,
            @PathVariable UUID productId) {
        favoriteRepository.deleteByCustomerIdAndProductId(customerId, productId);
        return ResponseEntity.ok("Removed from favorites");
    }

    @GetMapping("/{customerId}/{productId}/check")
    public ResponseEntity<Boolean> checkFavorite(
            @PathVariable UUID customerId,
            @PathVariable UUID productId) {
        return ResponseEntity.ok(favoriteRepository.existsByCustomerIdAndProductId(customerId, productId));
    }
}
