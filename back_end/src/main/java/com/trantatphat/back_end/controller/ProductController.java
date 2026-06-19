package com.trantatphat.back_end.controller;

import com.trantatphat.back_end.entity.Product;
import com.trantatphat.back_end.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductRepository productRepository;

    @GetMapping("/new")
    public ResponseEntity<List<Product>> getNewProducts() {
        // Trả về danh sách sản phẩm có gắn tag "NEW"
        List<Product> products = productRepository.findByTagName("NEW");
        return ResponseEntity.ok(products);
    }

    @GetMapping("/sale")
    public ResponseEntity<List<Product>> getSaleProducts() {
        // Trả về danh sách sản phẩm có gắn tag "SALE"
        List<Product> products = productRepository.findByTagName("SALE");
        return ResponseEntity.ok(products);
    }

    @GetMapping("/category/{categoryName}/top-rated")
    public ResponseEntity<List<Product>> getTopRatedProductsByCategory(@PathVariable String categoryName) {
        // Trả về danh sách sản phẩm có rating từ 3.0 đến 5.0
        List<Product> products = productRepository.findByCategoryNameAndRatingBetween(categoryName, 3.0, 5.0);
        return ResponseEntity.ok(products);
    }
}
