package com.example.auth.controller;

import com.example.auth.entity.Customer;
import com.example.auth.entity.Product;
import com.example.auth.entity.Review;
import com.example.auth.repository.CustomerRepository;
import com.example.auth.repository.ProductRepository;
import com.example.auth.repository.ReviewRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
// ✅ FIX: Bỏ /api prefix
@RequestMapping("/shop/reviews")
@RequiredArgsConstructor
@CrossOrigin
public class ReviewController {

    private final ReviewRepository reviewRepository;
    private final CustomerRepository customerRepository;
    private final ProductRepository productRepository;

    @GetMapping("/product/{productId}")
    public ResponseEntity<List<Review>> getProductReviews(@PathVariable UUID productId) {
        return ResponseEntity.ok(reviewRepository.findByProductId(productId));
    }

    @PostMapping("/{customerId}/{productId}")
    public ResponseEntity<?> submitReview(
            @PathVariable UUID customerId,
            @PathVariable UUID productId,
            @RequestBody Map<String, Object> body) {

        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new RuntimeException("Customer not found"));
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));

        Review review = Review.builder()
                .customer(customer)
                .product(product)
                .rating((Integer) body.get("rating"))
                .comment((String) body.get("comment"))
                .photos((String) body.getOrDefault("photos", "[]"))
                .build();

        return ResponseEntity.ok(reviewRepository.save(review));
    }

    @PostMapping("/{reviewId}/helpful")
    public ResponseEntity<?> markHelpful(@PathVariable UUID reviewId) {
        return reviewRepository.findById(reviewId).map(r -> {
            r.setHelpful_count(r.getHelpful_count() + 1);
            return ResponseEntity.ok(reviewRepository.save(r));
        }).orElse(ResponseEntity.notFound().build());
    }
}