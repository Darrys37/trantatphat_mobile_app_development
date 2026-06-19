package com.trantatphat.back_end.repository;

import com.trantatphat.back_end.entity.User;
import com.trantatphat.back_end.entity.UserAddress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface UserAddressRepository extends JpaRepository<UserAddress, UUID> {
    List<UserAddress> findByUser(User user);
}
