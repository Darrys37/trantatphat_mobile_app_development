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
@Order(15)
public class BeltsSeeder implements CommandLineRunner {

    private final ProductRepository productRepository;
    private final GalleryRepository galleryRepository;
    private final CategoryRepository categoryRepository;
    private final ProductCategoryRepository productCategoryRepository;

    @Override
    public void run(String... args) throws Exception {
        boolean hasBelts = false;
        Category beltsOpt = categoryRepository.findByCategoryName("Belts").orElse(null);
        if (beltsOpt != null) {
            for (ProductCategory pc : productCategoryRepository.findAll()) {
                if (pc.getCategory().getId().equals(beltsOpt.getId())) {
                    hasBelts = true;
                    break;
                }
            }
        }

        if (hasBelts) {
            System.out.println("Belts already seeded");
            return;
        }

        Category accessories = categoryRepository.findByCategoryName("Accessories").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Accessories").build())
        );

        Category belts = categoryRepository.findByCategoryName("Belts").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Belts").parent(accessories).build())
        );

        String[] images = {
            "belts1.jpg", "belts2.jpg", "belts3.jpg", "belts4.jpg", "belts5.jpg"
        };

        String[] names = {
            "Classic Leather Belt", "Woven Braided Belt", "Reversible Dress Belt", 
            "Studded Casual Belt", "Designer Logo Belt"
        };

        String[] brands = {
            "Levis", "Tommy Hilfiger", "Calvin Klein", "Diesel", "Hermes"
        };

        for (int i = 0; i < images.length; i++) {
            String img = images[i];
            String name = names[i];
            String brand = brands[i];

            Product p = Product.builder()
                .slug(img.replace(".jpg", "") + "-" + UUID.randomUUID().toString().substring(0, 8))
                .name(name)
                .sku("BELTS-SKU-" + i)
                .salePrice(35.0 + (i * 20))
                .comparePrice(50.0 + (i * 20))
                .buyingPrice(15.0)
                .quantity(300)
                .shortDescription("Premium " + name)
                .description("Detailed description for " + name + " from " + brand)
                .productType(brand)
                .published(true)
                .disableOutOfStock(false)
                .rating(4.7 + (i % 2) * 0.1)
                .reviewCount(80 + i * 10)
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
                .category(belts)
                .build();

            productCategoryRepository.save(pc);
        }

        System.out.println("Seeded " + images.length + " belts products.");
    }
}
