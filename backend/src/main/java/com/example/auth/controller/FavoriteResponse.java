package com.example.auth.controller;

import com.example.auth.entity.Favorite;
import com.example.auth.entity.Product;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.Date;
import java.util.UUID;

@Getter @Setter @NoArgsConstructor
public class FavoriteResponse {

    private UUID id;
    private String selected_size;
    private String selected_color;
    private Date created_at;
    private ProductSummary product;

    public FavoriteResponse(Favorite fav) {
        this.id             = fav.getId();
        this.selected_size  = fav.getSelected_size();
        this.selected_color = fav.getSelected_color();
        this.created_at     = fav.getCreated_at();
        if (fav.getProduct() != null) {
            this.product = new ProductSummary(fav.getProduct());
        }
    }

    @Getter @Setter @NoArgsConstructor
    public static class ProductSummary {
        private UUID id;
        private String slug;
        private String product_name;
        private String sku;
        private BigDecimal sale_price;
        private BigDecimal compare_price;
        private Integer quantity;
        private String short_description;
        private String product_type;
        private boolean published;
        private boolean disable_out_of_stock;

        public ProductSummary(Product p) {
            this.id                    = p.getId();
            this.slug                  = p.getSlug();
            this.product_name          = p.getProduct_name();
            this.sku                   = p.getSku();
            this.sale_price            = p.getSale_price();
            this.compare_price         = p.getCompare_price();
            this.quantity              = p.getQuantity();
            this.short_description     = p.getShort_description();
            this.product_type          = p.getProduct_type();
            this.published             = p.isPublished();
            this.disable_out_of_stock  = p.isDisable_out_of_stock();
        }
    }
}
