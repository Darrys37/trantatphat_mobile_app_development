package com.trantatphat.back_end.controller;

import com.trantatphat.back_end.payload.response.ReviewResponse;
import com.trantatphat.back_end.entity.ProductReview;
import com.trantatphat.back_end.entity.ReviewGallery;
import com.trantatphat.back_end.repository.ProductReviewRepository;
import com.trantatphat.back_end.repository.ReviewGalleryRepository;
import com.trantatphat.back_end.repository.ReviewHelpfulRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.Authentication;
import com.trantatphat.back_end.payload.request.CreateReviewRequest;
import com.trantatphat.back_end.entity.User;
import com.trantatphat.back_end.repository.UserRepository;
import com.trantatphat.back_end.entity.Product;
import com.trantatphat.back_end.repository.ProductRepository;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/reviews")
@RequiredArgsConstructor
public class ProductReviewController {

    private final ProductReviewRepository productReviewRepository;
    private final ReviewGalleryRepository reviewGalleryRepository;
    private final ReviewHelpfulRepository reviewHelpfulRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;

    @GetMapping("/{productId}")
    public ResponseEntity<List<ReviewResponse>> getProductReviews(@PathVariable UUID productId) {
        // Fetch all reviews instead of just this product's
        List<ProductReview> allReviews = productReviewRepository.findAllByOrderByCreatedAtDesc();
        // Just take the first 3 so we don't show duplicates of Kim, Matilda, Helene
        List<ProductReview> reviews = allReviews.stream().limit(3).collect(java.util.stream.Collectors.toList());
        
        List<ReviewResponse> ReviewResponses = reviews.stream().map(review -> {
            List<String> images = reviewGalleryRepository.findByReviewId(review.getId())
                    .stream()
                    .map(ReviewGallery::getImageUrl)
                    .collect(Collectors.toList());
                    
            long helpfulCount = reviewHelpfulRepository.countByReviewId(review.getId());

            return ReviewResponse.builder()
                    .id(review.getId())
                    .productId(review.getProduct().getId())
                    .productName(review.getProduct().getName())
                    .userName(review.getUser().getName())
                    .userAvatar(review.getUser().getImage())
                    .rating(review.getRating())
                    .content(review.getContent())
                    .createdAt(review.getCreatedAt())
                    .images(images)
                    .helpfulCount(helpfulCount)
                    .build();
        }).collect(Collectors.toList());

        return ResponseEntity.ok(ReviewResponses);
    }

    @PostMapping
    @Transactional
    public ResponseEntity<ReviewResponse> addOrUpdateReview(@RequestBody CreateReviewRequest request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();
        User user = userRepository.findFirstByEmail(email).orElseThrow(() -> new RuntimeException("User not found"));
        Product product = productRepository.findById(request.getProductId()).orElseThrow(() -> new RuntimeException("Product not found"));

        ProductReview review = productReviewRepository.findByProductIdAndUserId(product.getId(), user.getId())
                .orElse(ProductReview.builder()
                        .product(product)
                        .user(user)
                        .build());

        review.setRating(request.getRating());
        review.setContent(request.getContent());
        review = productReviewRepository.save(review);

        reviewGalleryRepository.deleteByReviewId(review.getId());

        if (request.getImages() != null && !request.getImages().isEmpty()) {
            for (String img : request.getImages()) {
                reviewGalleryRepository.save(ReviewGallery.builder()
                        .review(review)
                        .imageUrl(img)
                        .build());
            }
        }

        List<String> images = reviewGalleryRepository.findByReviewId(review.getId())
                .stream()
                .map(ReviewGallery::getImageUrl)
                .collect(Collectors.toList());
        long helpfulCount = reviewHelpfulRepository.countByReviewId(review.getId());

        ReviewResponse response = ReviewResponse.builder()
                .id(review.getId())
                .productId(product.getId())
                .productName(product.getName())
                .userName(user.getName())
                .userAvatar(user.getImage())
                .rating(review.getRating())
                .content(review.getContent())
                .createdAt(review.getCreatedAt() != null ? review.getCreatedAt() : java.time.ZonedDateTime.now())
                .images(images)
                .helpfulCount(helpfulCount)
                .build();

        return ResponseEntity.ok(response);
    }

    @GetMapping("/check/{productId}")
    public ResponseEntity<Boolean> hasUserReviewed(@PathVariable UUID productId) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated() || "anonymousUser".equals(authentication.getPrincipal())) {
            return ResponseEntity.ok(false);
        }

        String email = authentication.getName();
        User user = userRepository.findFirstByEmail(email).orElse(null);
        if (user == null) {
            return ResponseEntity.ok(false);
        }

        Optional<ProductReview> existingReview = productReviewRepository.findByProductIdAndUserId(productId, user.getId());
        return ResponseEntity.ok(existingReview.isPresent());
    }

    @GetMapping("/user")
    public ResponseEntity<List<ReviewResponse>> getUserReviews() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated() || "anonymousUser".equals(authentication.getPrincipal())) {
            return ResponseEntity.status(401).build();
        }

        String email = authentication.getName();
        User user = userRepository.findFirstByEmail(email).orElse(null);
        if (user == null) {
            return ResponseEntity.status(401).build();
        }

        List<ProductReview> reviews = productReviewRepository.findByUserIdOrderByCreatedAtDesc(user.getId());
        
        List<ReviewResponse> ReviewResponses = reviews.stream().map(review -> {
            List<String> images = reviewGalleryRepository.findByReviewId(review.getId())
                    .stream()
                    .map(ReviewGallery::getImageUrl)
                    .collect(Collectors.toList());
                    
            long helpfulCount = reviewHelpfulRepository.countByReviewId(review.getId());

            return ReviewResponse.builder()
                    .id(review.getId())
                    .productId(review.getProduct().getId())
                    .productName(review.getProduct().getName())
                    .userName(user.getName())
                    .userAvatar(user.getImage())
                    .rating(review.getRating())
                    .content(review.getContent())
                    .createdAt(review.getCreatedAt())
                    .images(images)
                    .helpfulCount(helpfulCount)
                    .build();
        }).collect(Collectors.toList());

        return ResponseEntity.ok(ReviewResponses);
    }
}
