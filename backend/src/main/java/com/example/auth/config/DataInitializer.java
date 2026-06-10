package com.example.auth.config;

import com.example.auth.entity.Role;
import com.example.auth.repository.RoleRepository;
import com.example.auth.entity.Product;
import com.example.auth.entity.Gallery;
import com.example.auth.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

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

        // Seeding mock products if empty
        if (productRepository.count() == 0) {
            log.info("🛒 Đang tạo sản phẩm mẫu trong Database...");

            saveProduct("Evening Dress", "evening-dress", "EVN-DRS-001", "12", "15", "Dorothy Perkins", 
                "https://images.pexels.com/photos/1755428/pexels-photo-1755428.jpeg?auto=compress&w=300");

            saveProduct("NewItem1", "new-item-1", "NEW-ITM-001", "10", null, "Mango", 
                "https://images.pexels.com/photos/1300550/pexels-photo-1300550.jpeg?auto=compress&w=300");

            saveProduct("Pullover", "pullover", "PUL-OVR-001", "51", null, "Mango", 
                "https://images.pexels.com/photos/1656684/pexels-photo-1656684.jpeg?auto=compress&w=400");

            saveProduct("T-shirt", "t-shirt", "TSH-RTS-001", "12", null, "Lime-shop", 
                "https://images.pexels.com/photos/1021693/pexels-photo-1021693.jpeg?auto=compress&w=400");

            saveProduct("Shirt", "shirt", "SHR-TTS-001", "51", null, "Topshop", 
                "https://images.pexels.com/photos/3622608/pexels-photo-3622608.jpeg?auto=compress&w=400");

            saveProduct("T-Shirt SPANISH", "t-shirt-spanish", "TSH-SPA-001", "9", "13", "Mango", 
                "https://images.pexels.com/photos/2220316/pexels-photo-2220316.jpeg?auto=compress&w=400");

            saveProduct("Crop Top", "crop-top", "CRP-TOP-001", "22", null, "Zara", 
                "https://images.pexels.com/photos/1536619/pexels-photo-1536619.jpeg?auto=compress&w=400");

            log.info("✅ Đã tạo xong sản phẩm mẫu trong Database");
        } else {
            log.info("ℹ️ Sản phẩm mẫu đã tồn tại");
        }
        
        log.info("📊 Tổng số role trong DB: {}", roleRepository.count());
    }

    private void saveProduct(String name, String slug, String sku, String salePrice, String comparePrice, String type, String imageUrl) {
        Product p = Product.builder()
                .product_name(name)
                .slug(slug)
                .sku(sku)
                .sale_price(new BigDecimal(salePrice))
                .compare_price(comparePrice != null ? new BigDecimal(comparePrice) : null)
                .quantity(15)
                .short_description("Short description of " + name)
                .product_description("This is a detailed product description of " + name + ".")
                .product_type(type)
                .published(true)
                .disable_out_of_stock(false)
                .build();

        Gallery g = Gallery.builder()
                .product(p)
                .image(imageUrl)
                .placeholder(imageUrl)
                .is_thumbnail(true)
                .build();

        p.setGalleries(List.of(g));
        productRepository.save(p);
    }
}