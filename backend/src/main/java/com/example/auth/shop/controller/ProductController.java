package com.example.auth.shop.controller;

import com.example.auth.shop.entity.Product;
import com.example.auth.shop.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/shop/products")
@RequiredArgsConstructor
@CrossOrigin
public class ProductController {
    private final ProductRepository productRepository;

    @GetMapping
    public ResponseEntity<List<Product>> getPublished() {
        return ResponseEntity.ok(productRepository.findByPublishedTrue());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> getById(@PathVariable UUID id) {
        return productRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Product> updateProduct(@PathVariable UUID id, @RequestBody Product updatedDetails) {
        return productRepository.findById(id)
                .map(product -> {
                    product.setProduct_name(updatedDetails.getProduct_name());
                    product.setSale_price(updatedDetails.getSale_price());
                    product.setCompare_price(updatedDetails.getCompare_price());
                    product.setBuying_price(updatedDetails.getBuying_price());
                    product.setQuantity(updatedDetails.getQuantity());
                    product.setShort_description(updatedDetails.getShort_description());
                    product.setProduct_description(updatedDetails.getProduct_description());
                    product.setProduct_type(updatedDetails.getProduct_type());
                    product.setPublished(updatedDetails.isPublished());
                    product.setDisable_out_of_stock(updatedDetails.isDisable_out_of_stock());
                    product.setSale(updatedDetails.isSale());
                    product.setNew(updatedDetails.isNew());
                    product.setNote(updatedDetails.getNote());
                    return ResponseEntity.ok(productRepository.save(product));
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
