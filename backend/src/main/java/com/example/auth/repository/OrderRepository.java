package com.example.auth.repository;

import com.example.auth.entity.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

@Repository
public interface OrderRepository extends JpaRepository<Order, String> {

    @Query("SELECT o FROM Order o WHERE o.customer.id = :customerId ORDER BY o.created_at DESC")
    List<Order> findByCustomerIdOrderByCreated_atDesc(@Param("customerId") UUID customerId);

    List<Order> findByOrderStatusId(UUID statusId);
}