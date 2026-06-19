package com.trantatphat.back_end.repository;

import com.trantatphat.back_end.entity.Favorite;
import com.trantatphat.back_end.entity.Product;
import com.trantatphat.back_end.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

@Repository
public interface FavoriteRepository extends JpaRepository<Favorite, UUID> {
    @Query("SELECT f FROM Favorite f JOIN FETCH f.product WHERE f.user = :user ORDER BY f.createdAt DESC")
    List<Favorite> findByUserOrderByCreatedAtDesc(@Param("user") User user);
    Optional<Favorite> findByUserAndProduct(User user, Product product);
    boolean existsByUserAndProduct(User user, Product product);
    void deleteByUserAndProduct(User user, Product product);
}
