package com.example.auth.repository;

import com.example.auth.entity.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface OrderStatusRepository extends JpaRepository<OrderStatus, UUID> {

    @Query("SELECT s FROM OrderStatus s WHERE s.status_name = :statusName")
    Optional<OrderStatus> findByStatusName(@Param("statusName") String statusName);
}