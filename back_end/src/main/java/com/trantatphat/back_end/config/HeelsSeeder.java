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
@Order(4)
public class HeelsSeeder implements CommandLineRunner {

    private final ProductRepository productRepository;
    private final GalleryRepository galleryRepository;
    private final CategoryRepository categoryRepository;
    private final ProductCategoryRepository productCategoryRepository;

    @Override
    public void run(String... args) throws Exception {
        boolean hasHeels = false;
        for (Product p : productRepository.findAll()) {
            if (p.getName() != null && p.getName().toLowerCase().contains("heels")) {
                hasHeels = true;
                break;
            }
        }

        if (hasHeels) {
            System.out.println("Heels already seeded");
            return;
        }

        Category shoes = categoryRepository.findByCategoryName("Shoes").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Shoes").build())
        );

        Category heels = categoryRepository.findByCategoryName("Heels").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Heels").parent(shoes).build())
        );

        String[] images = {
            "heels1.jpg", "heels2.jpg", "heels3.jpg", "heels4.jpg", "heels5.jpg",
            "heels6.jpg", "heels7.jpg", "heels8.jpg", "heels9.jpg", "heels10.jpg"
        };

        String[] names = {
            "Classic Stiletto Heels", "Pointed Toe Pumps", "Strappy Block Heels", 
            "Platform High Heels", "Ankle Strap Sandals", "Kitten Heel Mules", 
            "Clear Chunky Heels", "Lace-Up Party Heels", "Suede Slingbacks", "Metallic Evening Heels"
        };

        String[] brands = {
            "Christian Louboutin", "Jimmy Choo", "Steve Madden", "Aldo", "Nine West",
            "Zara", "Gucci", "Valentino", "Manolo Blahnik", "Prada"
        };

        for (int i = 0; i < images.length; i++) {
            String img = images[i];
            String name = names[i];
            String brand = brands[i];

            Product p = Product.builder()
                .slug(img.replace(".jpg", "") + "-" + UUID.randomUUID().toString().substring(0, 8))
                .name(name)
                .sku("HEELS-SKU-" + i)
                .salePrice(70.0 + (i * 8))
                .comparePrice(110.0 + (i * 8))
                .buyingPrice(45.0)
                .quantity(70)
                .shortDescription("Premium " + name)
                .description("Detailed description for " + name + " from " + brand)
                .productType(brand)
                .published(true)
                .disableOutOfStock(false)
                .rating(4.3 + (i % 7) * 0.1)
                .reviewCount(25 + i * 3)
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
                .category(heels)
                .build();

            productCategoryRepository.save(pc);
        }

        System.out.println("Seeded " + images.length + " heels products.");
    }
}
