package com.example.auth.repository;

import com.example.auth.entity.CardItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface CardItemRepository extends JpaRepository<CardItem, UUID> {

    @Query("SELECT ci FROM CardItem ci WHERE ci.card.id = :cardId AND ci.product.id = :productId " +
           "AND (:size IS NULL OR ci.selected_size = :size) " +
           "AND (:color IS NULL OR ci.selected_color = :color)")
    Optional<CardItem> findByCardAndProductAndVariant(
            @Param("cardId") UUID cardId,
            @Param("productId") UUID productId,
            @Param("size") String size,
            @Param("color") String color);

    void deleteByCardId(UUID cardId);
}
