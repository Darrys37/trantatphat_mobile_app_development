package com.example.auth.repository;

import com.example.auth.entity.Sell;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface SellRepository extends JpaRepository<Sell, UUID> {
    Optional<Sell> findByProductId(UUID productId);

    /** Top sản phẩm bán chạy */
    @Query("SELECT s FROM Sell s ORDER BY s.quantity DESC")
    List<Sell> findTopSelling();
}
