package com.trantatphat.back_end.payload.response;

import lombok.Builder;
import lombok.Data;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.UUID;

@Data
@Builder
public class ReviewResponse {
    private UUID id;
    private UUID productId;
    private String productName;
    private String userName;
    private String userAvatar;
    private Double rating;
    private String content;
    private ZonedDateTime createdAt;
    private List<String> images;
    private long helpfulCount;
}
