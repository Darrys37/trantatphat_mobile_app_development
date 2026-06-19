package com.trantatphat.back_end.repository;

import com.trantatphat.back_end.entity.ReviewHelpful;
import com.trantatphat.back_end.entity.ReviewHelpfulId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface ReviewHelpfulRepository extends JpaRepository<ReviewHelpful, ReviewHelpfulId> {
    long countByReviewId(UUID reviewId);
}
