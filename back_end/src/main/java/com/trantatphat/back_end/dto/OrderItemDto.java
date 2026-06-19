package com.trantatphat.back_end.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderItemDto {
    private String productId;
    private String image;
    private String productName;
    private String brand;
    private String color;
    private String size;
    private Integer units;
    private Double price;
}
