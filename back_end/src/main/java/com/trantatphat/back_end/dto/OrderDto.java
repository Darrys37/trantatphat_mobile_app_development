package com.trantatphat.back_end.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderDto {
    private String id;
    private String trackingNumber;
    private Integer quantity;
    private Double totalAmount;
    private String date;
    private String status;
}
