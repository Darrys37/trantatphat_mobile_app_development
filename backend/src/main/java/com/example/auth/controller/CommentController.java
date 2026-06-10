package com.example.auth.controller;

import com.example.auth.entity.Comment;
import com.example.auth.entity.Customer;
import com.example.auth.entity.Review;
import com.example.auth.repository.CommentRepository;
import com.example.auth.repository.CustomerRepository;
import com.example.auth.repository.ReviewRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * API quản lý comment dưới review sản phẩm.
 *
 * GET  /shop/comments/review/{reviewId}          → danh sách comment gốc của review
 * POST /shop/comments/review/{reviewId}/{customerId} → thêm comment mới
 * POST /shop/comments/{parentId}/reply/{customerId}  → reply một comment
 * POST /shop/comments/{commentId}/helpful            → tăng helpful count
 * DELETE /shop/comments/{commentId}                  → xoá comment (chủ sở hữu)
 */
@RestController
@RequestMapping("/shop/comments")
@RequiredArgsConstructor
@CrossOrigin
public class CommentController {

    private final CommentRepository commentRepository;
    private final ReviewRepository reviewRepository;
    private final CustomerRepository customerRepository;

    /** Lấy tất cả comment gốc (không phải reply) của một review */
    @GetMapping("/review/{reviewId}")
    public ResponseEntity<List<Comment>> getByReview(@PathVariable UUID reviewId) {
        return ResponseEntity.ok(
            commentRepository.findByReviewIdAndParentIsNullOrderByCreated_atDesc(reviewId));
    }

    /** Lấy reply của một comment cha */
    @GetMapping("/{parentId}/replies")
    public ResponseEntity<List<Comment>> getReplies(@PathVariable UUID parentId) {
        return ResponseEntity.ok(
            commentRepository.findByParentIdOrderByCreated_atAsc(parentId));
    }

    /** Thêm comment mới vào review */
    @PostMapping("/review/{reviewId}/{customerId}")
    public ResponseEntity<?> addComment(
            @PathVariable UUID reviewId,
            @PathVariable UUID customerId,
            @RequestBody Map<String, String> body) {

        Review review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new RuntimeException("Review not found"));
        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new RuntimeException("Customer not found"));

        Comment comment = Comment.builder()
                .review(review)
                .customer(customer)
                .content(body.getOrDefault("content", "").trim())
                .build();

        if (comment.getContent().isEmpty()) {
            return ResponseEntity.badRequest().body("Content is required");
        }

        return ResponseEntity.ok(commentRepository.save(comment));
    }

    /** Reply vào một comment cha */
    @PostMapping("/{parentId}/reply/{customerId}")
    public ResponseEntity<?> replyComment(
            @PathVariable UUID parentId,
            @PathVariable UUID customerId,
            @RequestBody Map<String, String> body) {

        Comment parent = commentRepository.findById(parentId)
                .orElseThrow(() -> new RuntimeException("Parent comment not found"));
        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new RuntimeException("Customer not found"));

        Comment reply = Comment.builder()
                .review(parent.getReview())
                .customer(customer)
                .parent(parent)
                .content(body.getOrDefault("content", "").trim())
                .build();

        if (reply.getContent().isEmpty()) {
            return ResponseEntity.badRequest().body("Content is required");
        }

        return ResponseEntity.ok(commentRepository.save(reply));
    }

    /** Đánh dấu comment hữu ích */
    @PostMapping("/{commentId}/helpful")
    public ResponseEntity<?> markHelpful(@PathVariable UUID commentId) {
        return commentRepository.findById(commentId).map(c -> {
            c.setHelpful_count(c.getHelpful_count() + 1);
            return ResponseEntity.ok(commentRepository.save(c));
        }).orElse(ResponseEntity.notFound().build());
    }

    /** Xoá comment */
    @DeleteMapping("/{commentId}")
    public ResponseEntity<?> deleteComment(@PathVariable UUID commentId) {
        if (!commentRepository.existsById(commentId)) {
            return ResponseEntity.notFound().build();
        }
        commentRepository.deleteById(commentId);
        return ResponseEntity.ok().build();
    }
}
