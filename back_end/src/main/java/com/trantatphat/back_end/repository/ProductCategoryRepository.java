package com.trantatphat.back_end.repository;

import com.trantatphat.back_end.entity.ProductCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface ProductCategoryRepository extends JpaRepository<ProductCategory, UUID> {
}
