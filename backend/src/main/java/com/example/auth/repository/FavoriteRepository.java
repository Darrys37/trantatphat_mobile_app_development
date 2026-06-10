package com.example.auth.repository;

import com.example.auth.entity.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface FavoriteRepository extends JpaRepository<Favorite, UUID> {

    // Fetch join để tránh LazyInitializationException khi serialize product
    @Query("SELECT f FROM Favorite f JOIN FETCH f.product WHERE f.customer.id = :customerId ORDER BY f.created_at DESC")
    List<Favorite> findByCustomerIdWithProduct(@Param("customerId") UUID customerId);

    // Giữ lại method cũ (vẫn dùng EAGER do entity đã sửa)
    List<Favorite> findByCustomerId(UUID customerId);

    Optional<Favorite> findByCustomerIdAndProductId(UUID customerId, UUID productId);

    void deleteByCustomerIdAndProductId(UUID customerId, UUID productId);

    boolean existsByCustomerIdAndProductId(UUID customerId, UUID productId);
}