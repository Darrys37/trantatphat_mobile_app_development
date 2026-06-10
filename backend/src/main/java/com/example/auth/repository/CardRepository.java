package com.example.auth.repository;

import com.example.auth.entity.Card;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface CardRepository extends JpaRepository<Card, UUID> {

    // Fetch join items + product để tránh N+1
    @Query("SELECT c FROM Card c LEFT JOIN FETCH c.items i LEFT JOIN FETCH i.product WHERE c.customer.id = :customerId")
    Optional<Card> findByCustomerIdWithItems(@Param("customerId") UUID customerId);

    Optional<Card> findByCustomerId(UUID customerId);
}
