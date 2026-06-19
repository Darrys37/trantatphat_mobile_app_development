package com.trantatphat.back_end.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderDetailsDto {
    private String id;
    private String trackingNumber;
    private Integer quantity;
    private Double totalAmount;
    private String date;
    private String status;
    private String shippingAddress;
    private String paymentMethod;
    private String deliveryMethod;
    private String discount;
    private List<OrderItemDto> items;
}
