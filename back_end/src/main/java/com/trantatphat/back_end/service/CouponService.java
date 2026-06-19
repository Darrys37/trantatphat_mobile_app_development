package com.trantatphat.back_end.service;

import com.trantatphat.back_end.entity.Cart;
import com.trantatphat.back_end.entity.Coupon;
import com.trantatphat.back_end.entity.User;
import com.trantatphat.back_end.payload.response.CouponResponse;
import com.trantatphat.back_end.repository.CartRepository;
import com.trantatphat.back_end.repository.CouponRepository;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.ZonedDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CouponService {

    private final CouponRepository couponRepository;
    private final CartRepository cartRepository;
    private final CartService cartService;

    @PostConstruct
    public void initMockCoupons() {
        if (couponRepository.count() == 0) {
            ZonedDateTime now = ZonedDateTime.now();
            Coupon coupon1 = Coupon.builder()
                    .code("mypromocode2020")
                    .title("Personal offer")
                    .discountType("PERCENTAGE")
                    .discountValue(10.0)
                    .couponStartDate(now.minusDays(1))
                    .couponEndDate(now.plusDays(6))
                    .timesUsed(0.0)
                    .build();

            Coupon coupon2 = Coupon.builder()
                    .code("summer2020")
                    .title("Summer Sale")
                    .discountType("PERCENTAGE")
                    .discountValue(15.0)
                    .couponStartDate(now.minusDays(5))
                    .couponEndDate(now.plusDays(23))
                    .timesUsed(0.0)
                    .build();

            Coupon coupon3 = Coupon.builder()
                    .code("personal22")
                    .title("Personal offer")
                    .discountType("PERCENTAGE")
                    .discountValue(22.0)
                    .couponStartDate(now.minusDays(2))
                    .couponEndDate(now.plusDays(6))
                    .timesUsed(0.0)
                    .build();

            couponRepository.saveAll(List.of(coupon1, coupon2, coupon3));
        }
    }

    public List<CouponResponse> getActiveCoupons() {
        ZonedDateTime now = ZonedDateTime.now();
        return couponRepository.findActiveCoupons(now).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public void applyCoupon(User user, String code) {
        ZonedDateTime now = ZonedDateTime.now();
        Coupon coupon = couponRepository.findByCode(code)
                .orElseThrow(() -> new RuntimeException("Coupon not found"));

        if (coupon.getCouponStartDate() != null && coupon.getCouponStartDate().isAfter(now)) {
            throw new RuntimeException("Coupon is not active yet");
        }
        if (coupon.getCouponEndDate() != null && coupon.getCouponEndDate().isBefore(now)) {
            throw new RuntimeException("Coupon has expired");
        }

        Cart cart = cartService.getOrCreateCart(user);
        cart.setCoupon(coupon);
        cartRepository.save(cart);
    }

    @Transactional
    public void removeCoupon(User user) {
        Cart cart = cartService.getOrCreateCart(user);
        cart.setCoupon(null);
        cartRepository.save(cart);
    }

    public CouponResponse mapToResponse(Coupon coupon) {
        Long remainingDays = null;
        if (coupon.getCouponEndDate() != null) {
            remainingDays = ChronoUnit.DAYS.between(ZonedDateTime.now(), coupon.getCouponEndDate());
            if (remainingDays < 0) remainingDays = 0L;
        }

        return CouponResponse.builder()
                .id(coupon.getId().toString())
                .code(coupon.getCode())
                .title(coupon.getTitle())
                .description(coupon.getDescription())
                .discountValue(coupon.getDiscountValue())
                .discountType(coupon.getDiscountType())
                .remainingDays(remainingDays)
                .build();
    }
}
