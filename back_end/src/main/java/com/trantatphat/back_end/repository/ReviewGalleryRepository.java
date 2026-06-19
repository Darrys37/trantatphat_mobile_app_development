package com.trantatphat.back_end.repository;

import com.trantatphat.back_end.entity.ReviewGallery;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.List;
import java.util.UUID;

@Repository
public interface ReviewGalleryRepository extends JpaRepository<ReviewGallery, UUID> {
    List<ReviewGallery> findByReviewId(UUID reviewId);
    void deleteByReviewId(UUID reviewId);
}
