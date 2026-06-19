package com.trantatphat.back_end.payload.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class CouponResponse {
    private String id;
    private String code;
    private String title;
    private String description;
    private Double discountValue;
    private String discountType; // "PERCENTAGE" or "FIXED"
    private Long remainingDays;
}
