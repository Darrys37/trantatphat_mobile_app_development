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
@Order(3)
public class SneakersSeeder implements CommandLineRunner {

    private final ProductRepository productRepository;
    private final GalleryRepository galleryRepository;
    private final CategoryRepository categoryRepository;
    private final ProductCategoryRepository productCategoryRepository;

    @Override
    public void run(String... args) throws Exception {
        boolean hasSneakers = false;
        for (Product p : productRepository.findAll()) {
            if (p.getName() != null && p.getName().toLowerCase().contains("sneaker")) {
                hasSneakers = true;
                break;
            }
        }

        if (hasSneakers) {
            System.out.println("Sneakers already seeded");
            return;
        }

        Category shoes = categoryRepository.findByCategoryName("Shoes").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Shoes").build())
        );

        Category sneakers = categoryRepository.findByCategoryName("Sneakers").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Sneakers").parent(shoes).build())
        );

        String[] images = {
            "sneaker1.jpg", "sneaker2.jpg", "sneaker3.jpg", "sneaker4.jpg", "sneaker5.jpg",
            "sneaker7.jpg", "sneaker8.jpg", "sneaker9.jpg", "sneaker10.jpg"
        };

        String[] names = {
            "Classic White Sneakers", "High-Top Canvas Sneakers", "Running Performance Sneakers", 
            "Casual Slip-On Sneakers", "Retro Leather Sneakers", "Chunky Platform Sneakers", 
            "Skateboarding Sneakers", "Breathable Mesh Sneakers", "Designer Fashion Sneakers"
        };

        String[] brands = {
            "Nike", "Adidas", "Puma", "Reebok", "Vans",
            "Converse", "New Balance", "Asics", "Balenciaga"
        };

        for (int i = 0; i < images.length; i++) {
            String img = images[i];
            String name = names[i];
            String brand = brands[i];

            Product p = Product.builder()
                .slug(img.replace(".jpg", "") + "-" + UUID.randomUUID().toString().substring(0, 8))
                .name(name)
                .sku("SNEAKER-SKU-" + i)
                .salePrice(60.0 + (i * 10))
                .comparePrice(90.0 + (i * 10))
                .buyingPrice(40.0)
                .quantity(100)
                .shortDescription("Premium " + name)
                .description("Detailed description for " + name + " from " + brand)
                .productType(brand)
                .published(true)
                .disableOutOfStock(false)
                .rating(4.2 + (i % 8) * 0.1)
                .reviewCount(20 + i * 2)
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
                .category(sneakers)
                .build();

            productCategoryRepository.save(pc);
        }

        System.out.println("Seeded " + images.length + " sneakers products.");
    }
}
