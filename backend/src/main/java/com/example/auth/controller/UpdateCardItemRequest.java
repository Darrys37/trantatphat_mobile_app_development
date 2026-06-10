package com.example.auth.controller;

import jakarta.validation.constraints.Min;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter @Setter @NoArgsConstructor
public class UpdateCardItemRequest {

    @Min(value = 0, message = "quantity must be >= 0 (0 = remove item)")
    private int quantity;
}
