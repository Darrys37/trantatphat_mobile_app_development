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
@Order(8)
public class LoafersSeeder implements CommandLineRunner {

    private final ProductRepository productRepository;
    private final GalleryRepository galleryRepository;
    private final CategoryRepository categoryRepository;
    private final ProductCategoryRepository productCategoryRepository;

    @Override
    public void run(String... args) throws Exception {
        boolean hasLoafers = false;
        Category loafersOpt = categoryRepository.findByCategoryName("Loafers").orElse(null);
        if (loafersOpt != null) {
            for (ProductCategory pc : productCategoryRepository.findAll()) {
                if (pc.getCategory().getId().equals(loafersOpt.getId())) {
                    hasLoafers = true;
                    break;
                }
            }
        }

        if (hasLoafers) {
            System.out.println("Loafers already seeded");
            return;
        }

        Category shoes = categoryRepository.findByCategoryName("Shoes").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Shoes").build())
        );

        Category loafers = categoryRepository.findByCategoryName("Loafers").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Loafers").parent(shoes).build())
        );

        String[] images = {
            "loafers1.jpg", "loafers2.jpg", "loafers3.jpg", "loafers4.jpg", "loafers5.jpg"
        };

        String[] names = {
            "Classic Penny Loafers", "Suede Tassel Loafers", "Chunky Sole Loafers", 
            "Leather Horsebit Loafers", "Slip-On Mule Loafers"
        };

        String[] brands = {
            "Gucci", "G.H. Bass & Co.", "Sam Edelman", "Cole Haan", "Everlane"
        };

        for (int i = 0; i < images.length; i++) {
            String img = images[i];
            String name = names[i];
            String brand = brands[i];

            Product p = Product.builder()
                .slug(img.replace(".jpg", "") + "-" + UUID.randomUUID().toString().substring(0, 8))
                .name(name)
                .sku("LOAFERS-SKU-" + i)
                .salePrice(60.0 + (i * 10))
                .comparePrice(85.0 + (i * 10))
                .buyingPrice(40.0)
                .quantity(100)
                .shortDescription("Premium " + name)
                .description("Detailed description for " + name + " from " + brand)
                .productType(brand)
                .published(true)
                .disableOutOfStock(false)
                .rating(4.6 + (i % 3) * 0.1)
                .reviewCount(35 + i * 8)
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
                .category(loafers)
                .build();

            productCategoryRepository.save(pc);
        }

        System.out.println("Seeded " + images.length + " loafers products.");
    }
}
