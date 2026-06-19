package com.trantatphat.back_end.payload.response;

import lombok.Builder;
import lombok.Data;
import java.util.UUID;

@Data
@Builder
public class CartItemResponse {
    private UUID id;
    private UUID productId;
    private String productName;
    private String productImageUrl;
    private Double price;
    private String color;
    private String size;
    private Integer quantity;
}
