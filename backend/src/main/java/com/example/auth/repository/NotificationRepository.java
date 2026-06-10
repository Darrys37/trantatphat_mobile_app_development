package com.example.auth.repository;

import com.example.auth.entity.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {

    @Query("SELECT n FROM Notification n WHERE n.account.id = :accountId ORDER BY n.created_at DESC")
    List<Notification> findByAccountIdOrderByCreated_atDesc(UUID accountId);

    List<Notification> findByAccountIdAndSeenFalse(UUID accountId);
}