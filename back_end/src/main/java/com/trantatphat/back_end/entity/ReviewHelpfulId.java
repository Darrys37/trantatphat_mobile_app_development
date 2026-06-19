package com.trantatphat.back_end.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReviewHelpfulId implements Serializable {
    private UUID reviewId;
    private UUID userId;
}
