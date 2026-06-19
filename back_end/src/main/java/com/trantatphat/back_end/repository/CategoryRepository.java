package com.trantatphat.back_end.repository;

import com.trantatphat.back_end.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface CategoryRepository extends JpaRepository<Category, UUID> {
    Optional<Category> findByCategoryName(String categoryName);
}
