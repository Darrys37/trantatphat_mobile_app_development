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
@Order(2)
public class BootsSeeder implements CommandLineRunner {

    private final ProductRepository productRepository;
    private final GalleryRepository galleryRepository;
    private final CategoryRepository categoryRepository;
    private final ProductCategoryRepository productCategoryRepository;

    @Override
    public void run(String... args) throws Exception {
        boolean hasBoots = false;
        for (Product p : productRepository.findAll()) {
            if (p.getName() != null && p.getName().toLowerCase().contains("boots")) {
                hasBoots = true;
                break;
            }
        }

        if (hasBoots) {
            System.out.println("Boots already seeded");
            return;
        }

        Category shoes = categoryRepository.findByCategoryName("Shoes").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Shoes").build())
        );

        Category boots = categoryRepository.findByCategoryName("Boots").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Boots").parent(shoes).build())
        );

        String[] images = {
            "boots1.jpg", "boots2.jpg", "boots3.jpg", "boots4.jpg", "boots5.jpg",
            "boots6.jpg", "boots7.jpg", "boots8.jpg", "boots9.jpg", "boots10.jpg"
        };

        String[] names = {
            "Classic Leather Boots", "Suede Ankle Boots", "Combat Boots", "Chelsea Boots", "Winter Snow Boots",
            "Heeled Knee Boots", "Riding Boots", "Platform Boots", "Chukka Boots", "Cowboy Boots"
        };

        String[] brands = {
            "Timberland", "Dr. Martens", "Clarks", "UGG", "Vans",
            "Steve Madden", "Aldo", "Nine West", "Skechers", "Cole Haan"
        };

        for (int i = 0; i < images.length; i++) {
            String img = images[i];
            String name = names[i];
            String brand = brands[i];

            Product p = Product.builder()
                .slug(img.replace(".jpg", "") + "-" + UUID.randomUUID().toString().substring(0, 8))
                .name(name)
                .sku("BOOTS-SKU-" + i)
                .salePrice(80.0 + (i * 5))
                .comparePrice(100.0 + (i * 5))
                .buyingPrice(50.0)
                .quantity(50)
                .shortDescription("Premium " + name)
                .description("Detailed description for " + name + " from " + brand)
                .productType(brand)
                .published(true)
                .disableOutOfStock(false)
                .rating(4.5 + (i % 5) * 0.1)
                .reviewCount(15 + i)
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
                .category(boots)
                .build();

            productCategoryRepository.save(pc);
        }

        System.out.println("Seeded " + images.length + " boots products.");
    }
}
