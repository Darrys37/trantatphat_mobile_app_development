package com.example.auth.controller;

import com.example.auth.entity.Category;
import com.example.auth.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
// ✅ FIX: Bỏ /api prefix
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