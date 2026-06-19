package com.trantatphat.back_end.payload.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateReviewRequest {
    private UUID productId;
    private Double rating;
    private String content;
    private List<String> images; // List of Base64 strings
}
