package com.example.auth.shop.repository;

import com.example.auth.shop.entity.ShopRole;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.UUID;

@Repository
public interface ShopRoleRepository extends JpaRepository<ShopRole, UUID> {}
