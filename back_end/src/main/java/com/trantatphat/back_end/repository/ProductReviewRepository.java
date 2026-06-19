package com.trantatphat.back_end.repository;

import com.trantatphat.back_end.entity.ProductReview;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ProductReviewRepository extends JpaRepository<ProductReview, UUID> {
    List<ProductReview> findAllByOrderByCreatedAtDesc();
    List<ProductReview> findByProductIdOrderByCreatedAtDesc(UUID productId);
    List<ProductReview> findByUserIdOrderByCreatedAtDesc(UUID userId);
    Optional<ProductReview> findByProductIdAndUserId(UUID productId, UUID userId);
}
