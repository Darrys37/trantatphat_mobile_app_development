package com.example.auth.controller;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

@Getter @Setter @NoArgsConstructor
public class AddToCardRequest {

    @NotNull(message = "productId is required")
    private UUID productId;

    @Min(value = 1, message = "quantity must be at least 1")
    private int quantity = 1;

    private String selected_size;
    private String selected_color;
}
