package com.trantatphat.back_end.repository;

import com.trantatphat.back_end.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
// Kế thừa JpaRepository và chỉ định <Thực thể quản lý, Kiểu dữ liệu của Khóa chính>
public interface UserRepository extends JpaRepository<User, UUID> {

    // 1. Tìm kiếm người dùng dựa vào Email (Trả về dạng Optional để tránh lỗi NullPointerException)
    Optional<User> findFirstByEmail(String email);

    // 2. Kiểm tra xem Email này đã được ai đăng ký trong Database chưa (Trả về true/false)
    Boolean existsByEmail(String email);
}
