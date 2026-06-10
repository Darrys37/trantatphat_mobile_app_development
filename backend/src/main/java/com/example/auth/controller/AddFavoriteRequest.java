package com.example.auth.controller;

import lombok.*;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class AddFavoriteRequest {
    private String selected_size;
    private String selected_color;
}
