package com.trantatphat.back_end.repository;

import com.trantatphat.back_end.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface ProductRepository extends JpaRepository<Product, UUID> {
    
    @Query("SELECT p FROM Product p JOIN p.tags t WHERE t.name = :tagName")
    List<Product> findByTagName(@Param("tagName") String tagName);

    List<Product> findBySalePriceIsNotNull();

    @Query("SELECT pc.product FROM ProductCategory pc WHERE pc.category.categoryName = :categoryName AND pc.product.rating >= :minRating AND pc.product.rating <= :maxRating ORDER BY pc.product.rating DESC")
    List<Product> findByCategoryNameAndRatingBetween(@Param("categoryName") String categoryName, @Param("minRating") Double minRating, @Param("maxRating") Double maxRating);
}
