package com.example.auth.controller;

import com.example.auth.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/shop/home")
@CrossOrigin
@RequiredArgsConstructor
public class HomeLayoutController {

    private final ProductRepository productRepository;
    private final Map<UUID, String> productSectionMap = new LinkedHashMap<>();

    @GetMapping("/layout")
    public ResponseEntity<Map<String, List<String>>> getLayout() {
        List<ProductResponse> allProducts = productRepository.findByPublishedTrue()
                .stream().map(ProductResponse::new).collect(Collectors.toList());

        List<ProductResponse> saleItems = new ArrayList<>();
        List<ProductResponse> newItems  = new ArrayList<>();

        for (ProductResponse p : allProducts) {
            String section = productSectionMap.get(p.getId());
            if (section == null) {
                boolean hasDiscount = p.getCompare_price() != null
                        && p.getSale_price() != null
                        && p.getCompare_price().compareTo(p.getSale_price()) > 0;
                section = hasDiscount ? "sale" : "new";
                productSectionMap.put(p.getId(), section);
            }
            if ("sale".equals(section)) saleItems.add(p);
            else newItems.add(p);
        }

        return ResponseEntity.ok(Map.of(
            "sale", saleItems.stream().map(ProductResponse::getProduct_name).collect(Collectors.toList()),
            "new",  newItems.stream().map(ProductResponse::getProduct_name).collect(Collectors.toList())
        ));
    }

    @PutMapping("/move")
    public ResponseEntity<Map<String, Object>> moveProduct(@RequestBody Map<String, String> body) {
        String productIdStr  = body.get("productId");
        String targetSection = body.get("to");

        if (productIdStr == null || targetSection == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Thiếu 'productId' hoặc 'to'"));
        }
        if (!targetSection.equals("sale") && !targetSection.equals("new")) {
            return ResponseEntity.badRequest().body(Map.of("error", "'to' phải là 'sale' hoặc 'new'"));
        }

        UUID productId;
        try {
            productId = UUID.fromString(productIdStr);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", "productId không hợp lệ: " + productIdStr));
        }

        if (!productRepository.existsById(productId)) {
            return ResponseEntity.badRequest().body(Map.of("error", "Không tìm thấy product: " + productIdStr));
        }

        String oldSection = productSectionMap.getOrDefault(productId, "unknown");
        productSectionMap.put(productId, targetSection);

        return ResponseEntity.ok(Map.of(
            "productId", productIdStr,
            "from",      oldSection,
            "to",        targetSection,
            "message",   "Đã chuyển product " + productIdStr + " từ " + oldSection + " → " + targetSection
        ));
    }
}
