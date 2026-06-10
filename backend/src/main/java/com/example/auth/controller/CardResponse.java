package com.example.auth.controller;

import com.example.auth.entity.Card;
import com.example.auth.entity.CardItem;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Getter @Setter @NoArgsConstructor
public class CardResponse {

    private UUID id;
    private UUID customerId;
    private List<CardItemResponse> items;
    private int totalCount;
    private BigDecimal subtotal;

    public CardResponse(Card card) {
        this.id         = card.getId();
        this.customerId = card.getCustomer().getId();
        this.items      = card.getItems() == null ? List.of() :
                card.getItems().stream()
                        .map(CardItemResponse::new)
                        .collect(Collectors.toList());

        this.totalCount = this.items.stream().mapToInt(CardItemResponse::getQuantity).sum();
        this.subtotal   = this.items.stream()
                .map(i -> i.getUnit_price().multiply(BigDecimal.valueOf(i.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    @Getter @Setter @NoArgsConstructor
    public static class CardItemResponse {
        private UUID id;
        private UUID productId;
        private String product_name;
        private String thumbnail;
        private String sku;
        private BigDecimal unit_price;
        private BigDecimal compare_price;
        private int quantity;
        private String selected_size;
        private String selected_color;
        private BigDecimal subtotal;

        public CardItemResponse(CardItem ci) {
            this.id             = ci.getId();
            this.quantity       = ci.getQuantity() != null ? ci.getQuantity() : 1;
            this.selected_size  = ci.getSelected_size();
            this.selected_color = ci.getSelected_color();

            if (ci.getProduct() != null) {
                var p = ci.getProduct();
                this.productId     = p.getId();
                this.product_name  = p.getProduct_name();
                this.sku           = p.getSku();
                this.unit_price    = p.getSale_price();
                this.compare_price = p.getCompare_price();

                if (p.getGalleries() != null && !p.getGalleries().isEmpty()) {
                    this.thumbnail = p.getGalleries().stream()
                            .filter(g -> g.is_thumbnail())
                            .map(g -> g.getImage())
                            .findFirst()
                            .orElse(p.getGalleries().get(0).getImage());
                }
            } else {
                this.unit_price = BigDecimal.ZERO;
            }

            this.subtotal = this.unit_price != null
                    ? this.unit_price.multiply(BigDecimal.valueOf(this.quantity))
                    : BigDecimal.ZERO;
        }
    }
}
