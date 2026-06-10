package com.example.auth.repository;

import com.example.auth.entity.Comment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

@Repository
public interface CommentRepository extends JpaRepository<Comment, UUID> {

    /** Tất cả comment gốc (không phải reply) của một review, mới nhất trước */
    @Query("SELECT c FROM Comment c WHERE c.review.id = :reviewId AND c.parent IS NULL ORDER BY c.created_at DESC")
    List<Comment> findByReviewIdAndParentIsNullOrderByCreated_atDesc(@Param("reviewId") UUID reviewId);

    /** Reply con của một comment cha, cũ nhất trước */
    @Query("SELECT c FROM Comment c WHERE c.parent.id = :parentId ORDER BY c.created_at ASC")
    List<Comment> findByParentIdOrderByCreated_atAsc(@Param("parentId") UUID parentId);

    /** Tất cả comment của một khách hàng */
    List<Comment> findByCustomerId(UUID customerId);
}