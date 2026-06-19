package com.trantatphat.back_end.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "review_helpfuls")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@IdClass(ReviewHelpfulId.class)
public class ReviewHelpful {

    @Id
    @Column(name = "review_id")
    private UUID reviewId;

    @Id
    @Column(name = "user_id")
    private UUID userId;
}
