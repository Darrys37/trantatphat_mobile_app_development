package com.trantatphat.back_end.repository;

import com.trantatphat.back_end.entity.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import com.trantatphat.back_end.entity.User;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.Query;

@Repository
public interface OrderRepository extends JpaRepository<Order, String> {
    List<Order> findByUserOrderByCreatedAtDesc(User user);

    @EntityGraph(attributePaths = {"orderStatus"})
    @Query("SELECT o FROM Order o")
    List<Order> findAllWithStatus();
}
