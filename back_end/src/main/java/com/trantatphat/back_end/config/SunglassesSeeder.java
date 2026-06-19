package com.trantatphat.back_end.config;

import com.trantatphat.back_end.entity.Category;
import com.trantatphat.back_end.entity.Gallery;
import com.trantatphat.back_end.entity.Product;
import com.trantatphat.back_end.entity.ProductCategory;
import com.trantatphat.back_end.repository.CategoryRepository;
import com.trantatphat.back_end.repository.GalleryRepository;
import com.trantatphat.back_end.repository.ProductCategoryRepository;
import com.trantatphat.back_end.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.core.annotation.Order;

import java.util.UUID;

@Component
@RequiredArgsConstructor
@Order(13)
public class SunglassesSeeder implements CommandLineRunner {

    private final ProductRepository productRepository;
    private final GalleryRepository galleryRepository;
    private final CategoryRepository categoryRepository;
    private final ProductCategoryRepository productCategoryRepository;

    @Override
    public void run(String... args) throws Exception {
        boolean hasSunglasses = false;
        Category sunglassesOpt = categoryRepository.findByCategoryName("Sunglasses").orElse(null);
        if (sunglassesOpt != null) {
            for (ProductCategory pc : productCategoryRepository.findAll()) {
                if (pc.getCategory().getId().equals(sunglassesOpt.getId())) {
                    hasSunglasses = true;
                    break;
                }
            }
        }

        if (hasSunglasses) {
            System.out.println("Sunglasses already seeded");
            return;
        }

        Category accessories = categoryRepository.findByCategoryName("Accessories").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Accessories").build())
        );

        Category sunglasses = categoryRepository.findByCategoryName("Sunglasses").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Sunglasses").parent(accessories).build())
        );

        String[] images = {
            "Sunglasses1.jpg", "Sunglasses2.jpg", "Sunglasses3.jpg", "Sunglasses4.jpg", "Sunglasses5.jpg"
        };

        String[] names = {
            "Classic Aviator Sunglasses", "Retro Square Sunglasses", "Polarized Wayfarer", 
            "Oversized Cat Eye Sunglasses", "Round Metal Sunglasses"
        };

        String[] brands = {
            "Ray-Ban", "Oakley", "Prada", "Gucci", "Dior"
        };

        for (int i = 0; i < images.length; i++) {
            String img = images[i];
            String name = names[i];
            String brand = brands[i];

            Product p = Product.builder()
                .slug(img.replace(".jpg", "") + "-" + UUID.randomUUID().toString().substring(0, 8))
                .name(name)
                .sku("SUNGLASSES-SKU-" + i)
                .salePrice(120.0 + (i * 30))
                .comparePrice(150.0 + (i * 30))
                .buyingPrice(50.0)
                .quantity(100)
                .shortDescription("Premium " + name)
                .description("Detailed description for " + name + " from " + brand)
                .productType(brand)
                .published(true)
                .disableOutOfStock(false)
                .rating(4.7 + (i % 3) * 0.1)
                .reviewCount(100 + i * 20)
                .build();

            productRepository.save(p);

            Gallery g = Gallery.builder()
                .product(p)
                .image("assets/" + img)
                .placeholder("assets/" + img)
                .isThumbnail(true)
                .build();

            galleryRepository.save(g);

            ProductCategory pc = ProductCategory.builder()
                .product(p)
                .category(sunglasses)
                .build();

            productCategoryRepository.save(pc);
        }

        System.out.println("Seeded " + images.length + " sunglasses products.");
    }
}
