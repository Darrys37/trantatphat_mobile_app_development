package com.trantatphat.back_end.payload.request;

import lombok.Data;
import java.util.UUID;

@Data
public class CartItemRequest {
    private UUID productId;
    private String color;
    private String size;
    private Integer quantity;
}
