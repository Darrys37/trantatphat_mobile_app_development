package com.example.auth.repository;

import com.example.auth.entity.VariantOption;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

@Repository
public interface VariantOptionRepository extends JpaRepository<VariantOption, UUID> {
    List<VariantOption> findByProductId(UUID productId);
    List<VariantOption> findByProductIdAndActiveTrue(UUID productId);
}
