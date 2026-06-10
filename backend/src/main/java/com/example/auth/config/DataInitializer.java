package com.example.auth.config;

import com.example.auth.auth.entity.Role;
import com.example.auth.auth.repository.RoleRepository;
import com.example.auth.shop.entity.Product;
import com.example.auth.shop.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataInitializer {
    
    private final RoleRepository roleRepository;
    private final ProductRepository productRepository;
    
    @EventListener(ApplicationReadyEvent.class)
    @Transactional
    public void init() {
        log.info("🚀 DataInitializer đang khởi chạy...");
        
        if (roleRepository.findByName("ROLE_USER").isEmpty()) {
            roleRepository.save(Role.builder().name("ROLE_USER").build());
            log.info("✅ Đã tạo ROLE_USER trong Database");
        } else {
            log.info("ℹ️ ROLE_USER đã tồn tại");
        }
        
        if (roleRepository.findByName("ROLE_ADMIN").isEmpty()) {
            roleRepository.save(Role.builder().name("ROLE_ADMIN").build());
            log.info("✅ Đã tạo ROLE_ADMIN trong Database");
        } else {
            log.info("ℹ️ ROLE_ADMIN đã tồn tại");
        }
        
        // ⭐ Tự động seed sản phẩm mẫu nếu chưa có
        if (productRepository.findAll().stream().noneMatch(p -> p.getProduct_name().equalsIgnoreCase("Evening Dress"))) {
            Product eveningDress = Product.builder()
                    .slug("evening-dress")
                    .product_name("Evening Dress")
                    .sku("Dorothy Perkins")
                    .sale_price(new BigDecimal("12.00"))
                    .compare_price(new BigDecimal("15.00"))
                    .buying_price(new BigDecimal("8.00"))
                    .quantity(10)
                    .short_description("Beautiful evening dress")
                    .product_description("Perfect for formal events and dinner parties.")
                    .product_type("simple")
                    .published(true)
                    .disable_out_of_stock(false)
                    .isSale(true)
                    .isNew(false)
                    .build();
            productRepository.save(eveningDress);
            log.info("✅ Tự động tạo sản phẩm mẫu: Evening Dress");
        }
        
        if (productRepository.findAll().stream().noneMatch(p -> p.getProduct_name().equalsIgnoreCase("Sport Dress"))) {
            Product sportDress = Product.builder()
                    .slug("sport-dress")
                    .product_name("Sport Dress")
                    .sku("Sitlly")
                    .sale_price(new BigDecimal("19.00"))
                    .compare_price(new BigDecimal("22.00"))
                    .buying_price(new BigDecimal("10.00"))
                    .quantity(10)
                    .short_description("Sporty summer dress")
                    .product_description("Perfect for active lifestyle.")
                    .product_type("simple")
                    .published(true)
                    .disable_out_of_stock(false)
                    .isSale(true)
                    .isNew(false)
                    .build();
            productRepository.save(sportDress);
            log.info("✅ Tự động tạo sản phẩm mẫu: Sport Dress");
        }

        if (productRepository.findAll().stream().noneMatch(p -> p.getProduct_name().equalsIgnoreCase("White Sport Dress"))) {
            Product whiteSportDress = Product.builder()
                    .slug("assets/images/main_2_sport_white.png")
                    .product_name("White Sport Dress")
                    .sku("Dorothy")
                    .sale_price(new BigDecimal("14.00"))
                    .compare_price(new BigDecimal("18.00"))
                    .buying_price(new BigDecimal("9.00"))
                    .quantity(15)
                    .short_description("Elegant white sporty dress")
                    .product_description("Breathable fabric for maximum comfort.")
                    .product_type("simple")
                    .published(true)
                    .disable_out_of_stock(false)
                    .isSale(true)
                    .isNew(false)
                    .build();
            productRepository.save(whiteSportDress);
            log.info("✅ Tự động tạo sản phẩm mẫu: White Sport Dress");
        }

        if (productRepository.findAll().stream().noneMatch(p -> p.getProduct_name().equalsIgnoreCase("Chiffon Summer Dress"))) {
            Product chiffonDress = Product.builder()
                    .slug("assets/images/main_page_1.png")
                    .product_name("Chiffon Summer Dress")
                    .sku("Lulus")
                    .sale_price(new BigDecimal("24.00"))
                    .compare_price(new BigDecimal("30.00"))
                    .buying_price(new BigDecimal("12.00"))
                    .quantity(8)
                    .short_description("Light chiffon floral dress")
                    .product_description("Flowy dress ideal for warm sunny days.")
                    .product_type("simple")
                    .published(true)
                    .disable_out_of_stock(false)
                    .isSale(true)
                    .isNew(false)
                    .build();
            productRepository.save(chiffonDress);
            log.info("✅ Tự động tạo sản phẩm mẫu: Chiffon Summer Dress");
        }

        if (productRepository.findAll().stream().noneMatch(p -> p.getProduct_name().equalsIgnoreCase("Striped T-Shirt"))) {
            Product stripedTee = Product.builder()
                    .slug("assets/images/main_2_new_bottom_2.png")
                    .product_name("Striped T-Shirt")
                    .sku("Zara")
                    .sale_price(new BigDecimal("15.00"))
                    .compare_price(new BigDecimal("18.00"))
                    .buying_price(new BigDecimal("7.00"))
                    .quantity(20)
                    .short_description("Fashionable striped t-shirt")
                    .product_description("Red and white stripe pattern casual wear.")
                    .product_type("simple")
                    .published(true)
                    .disable_out_of_stock(false)
                    .isSale(false)
                    .isNew(true)
                    .build();
            productRepository.save(stripedTee);
            log.info("✅ Tự động tạo sản phẩm mẫu: Striped T-Shirt");
        }

        if (productRepository.findAll().stream().noneMatch(p -> p.getProduct_name().equalsIgnoreCase("Classic White Tee"))) {
            Product whiteTee = Product.builder()
                    .slug("assets/images/main_2_new_bottom_3.png")
                    .product_name("Classic White Tee")
                    .sku("Mango")
                    .sale_price(new BigDecimal("12.00"))
                    .compare_price(new BigDecimal("15.00"))
                    .buying_price(new BigDecimal("5.00"))
                    .quantity(25)
                    .short_description("Comfortable cotton white tee")
                    .product_description("Breathable white tee for everyday basic look.")
                    .product_type("simple")
                    .published(true)
                    .disable_out_of_stock(false)
                    .isSale(false)
                    .isNew(true)
                    .build();
            productRepository.save(whiteTee);
            log.info("✅ Tự động tạo sản phẩm mẫu: Classic White Tee");
        }
        
        log.info("📊 Tổng số role trong DB: {}", roleRepository.count());
        log.info("📊 Tổng số sản phẩm trong DB: {}", productRepository.count());
    }
}