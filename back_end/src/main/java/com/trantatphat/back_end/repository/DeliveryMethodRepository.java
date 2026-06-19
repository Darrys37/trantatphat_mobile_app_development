package com.trantatphat.back_end.repository;

import com.trantatphat.back_end.entity.DeliveryMethod;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface DeliveryMethodRepository extends JpaRepository<DeliveryMethod, UUID> {
}
