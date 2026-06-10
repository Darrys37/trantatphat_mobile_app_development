package com.example.auth.shop.controller;

import com.example.auth.shop.entity.Product;
import com.example.auth.shop.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/shop/home")
@RequiredArgsConstructor
@CrossOrigin
public class HomeController {

    private final ProductRepository productRepository;

    @PutMapping("/move")
    public ResponseEntity<?> moveProduct(@RequestBody Map<String, String> request) {
        String productName = request.get("product");
        String toSection = request.get("to");

        if (productName == null || toSection == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Missing 'product' or 'to' parameters"));
        }

        // Find product by name (case-insensitive search)
        Optional<Product> productOpt = productRepository.findAll().stream()
                .filter(p -> p.getProduct_name().equalsIgnoreCase(productName))
                .findFirst();

        if (productOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "Sản phẩm '" + productName + "' không tìm thấy"));
        }

        Product product = productOpt.get();
        String fromSection = product.isSale() ? "sale" : (product.isNew() ? "new" : "none");

        if ("new".equalsIgnoreCase(toSection)) {
            product.setSale(false);
            product.setNew(true);
        } else if ("sale".equalsIgnoreCase(toSection)) {
            product.setSale(true);
            product.setNew(false);
        } else {
            product.setSale(false);
            product.setNew(false);
        }

        productRepository.save(product);

        Map<String, String> response = new HashMap<>();
        response.put("product", productName);
        response.put("to", toSection.toLowerCase());
        response.put("from", fromSection);
        response.put("message", "Đã chuyển '" + productName + "' từ " + fromSection + " -> " + toSection.toLowerCase());

        return ResponseEntity.ok(response);
    }
}
