package com.example.auth.repository;

import com.example.auth.entity.ShopRole;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.UUID;

@Repository
public interface ShopRoleRepository extends JpaRepository<ShopRole, UUID> {}
