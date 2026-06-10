package com.example.auth.shop.controller;

import com.example.auth.shop.entity.Category;
import com.example.auth.shop.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/shop/categories")
@RequiredArgsConstructor
@CrossOrigin
public class CategoryController {
    private final CategoryRepository categoryRepository;

    @GetMapping
    public ResponseEntity<List<Category>> getAll() {
        return ResponseEntity.ok(categoryRepository.findAll());
    }

    @GetMapping("/root")
    public ResponseEntity<List<Category>> getRootCategories() {
        return ResponseEntity.ok(categoryRepository.findByParentIsNull());
    }

    @GetMapping("/{id}/children")
    public ResponseEntity<List<Category>> getChildren(@PathVariable UUID id) {
        return ResponseEntity.ok(categoryRepository.findByParentId(id));
    }
}
