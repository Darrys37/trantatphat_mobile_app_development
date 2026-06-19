package com.trantatphat.back_end.repository;

import com.trantatphat.back_end.entity.Coupon;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface CouponRepository extends JpaRepository<Coupon, UUID> {
    
    Optional<Coupon> findByCode(String code);

    @Query("SELECT c FROM Coupon c WHERE c.couponStartDate <= :now AND c.couponEndDate >= :now")
    List<Coupon> findActiveCoupons(ZonedDateTime now);
}
