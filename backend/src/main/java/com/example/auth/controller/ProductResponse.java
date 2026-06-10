package com.example.auth.controller;

import com.example.auth.entity.Gallery;
import com.example.auth.entity.Product;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Getter @Setter @NoArgsConstructor
public class ProductResponse {

    private UUID id;
    private String slug;
    private String product_name;
    private String sku;
    private BigDecimal sale_price;
    private BigDecimal compare_price;
    private Integer quantity;
    private String short_description;
    private String product_description;
    private String product_type;
    private boolean published;
    private boolean disable_out_of_stock;
    private Date created_at;
    private Date updated_at;
    private String thumbnail;
    private List<GallerySummary> galleries;

    public ProductResponse(Product p) {
        this.id                   = p.getId();
        this.slug                 = p.getSlug();
        this.product_name         = p.getProduct_name();
        this.sku                  = p.getSku();
        this.sale_price           = p.getSale_price();
        this.compare_price        = p.getCompare_price();
        this.quantity             = p.getQuantity();
        this.short_description    = p.getShort_description();
        this.product_description  = p.getProduct_description();
        this.product_type         = p.getProduct_type();
        this.published            = p.isPublished();
        this.disable_out_of_stock = p.isDisable_out_of_stock();
        this.created_at           = p.getCreated_at();
        this.updated_at           = p.getUpdated_at();

        if (p.getGalleries() != null) {
            this.galleries = p.getGalleries().stream()
                    .map(GallerySummary::new)
                    .collect(Collectors.toList());

            this.thumbnail = p.getGalleries().stream()
                    .filter(Gallery::is_thumbnail)
                    .map(Gallery::getImage)
                    .findFirst()
                    .orElseGet(() -> p.getGalleries().isEmpty()
                            ? null
                            : p.getGalleries().get(0).getImage());
        }
    }

    @Getter @Setter @NoArgsConstructor
    public static class GallerySummary {
        private UUID id;
        private String image;
        private String placeholder;
        private boolean is_thumbnail;

        public GallerySummary(Gallery g) {
            this.id           = g.getId();
            this.image        = g.getImage();
            this.placeholder  = g.getPlaceholder();
            this.is_thumbnail = g.is_thumbnail();
        }
    }
}
