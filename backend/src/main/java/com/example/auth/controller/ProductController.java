package com.example.auth.controller;

import com.example.auth.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/shop/products")
@RequiredArgsConstructor
@CrossOrigin
public class ProductController {

    private final ProductRepository productRepository;

    @GetMapping
    public ResponseEntity<List<ProductResponse>> getPublished() {
        return ResponseEntity.ok(productRepository.findByPublishedTrue()
                .stream().map(ProductResponse::new).collect(Collectors.toList()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductResponse> getById(@PathVariable UUID id) {
        return productRepository.findById(id)
                .map(p -> ResponseEntity.ok(new ProductResponse(p)))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/slug/{slug}")
    public ResponseEntity<ProductResponse> getBySlug(@PathVariable String slug) {
        return productRepository.findBySlug(slug)
                .map(p -> ResponseEntity.ok(new ProductResponse(p)))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/{id}/related")
    public ResponseEntity<List<ProductResponse>> getRelated(@PathVariable UUID id) {
        List<ProductResponse> related = productRepository.findByPublishedTrue()
                .stream()
                .filter(p -> !p.getId().equals(id))
                .limit(10)
                .map(ProductResponse::new)
                .collect(Collectors.toList());
        return ResponseEntity.ok(related);
    }
}
