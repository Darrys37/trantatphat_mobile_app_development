package com.example.auth.repository;

import com.example.auth.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ProductRepository extends JpaRepository<Product, UUID> {

    List<Product> findByPublishedTrue();

    Optional<Product> findBySlug(String slug);

    // ✅ Tìm sản phẩm liên quan: cùng published, loại trừ chính nó
    @Query("SELECT p FROM Product p WHERE p.published = true AND p.id != :excludeId")
    List<Product> findRelated(UUID excludeId);
}
