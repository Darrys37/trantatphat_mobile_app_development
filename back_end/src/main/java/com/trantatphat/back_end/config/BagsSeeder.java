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
@Order(10)
public class BagsSeeder implements CommandLineRunner {

    private final ProductRepository productRepository;
    private final GalleryRepository galleryRepository;
    private final CategoryRepository categoryRepository;
    private final ProductCategoryRepository productCategoryRepository;

    @Override
    public void run(String... args) throws Exception {
        boolean hasBags = false;
        Category bagsOpt = categoryRepository.findByCategoryName("Bags").orElse(null);
        if (bagsOpt != null) {
            for (ProductCategory pc : productCategoryRepository.findAll()) {
                if (pc.getCategory().getId().equals(bagsOpt.getId())) {
                    hasBags = true;
                    break;
                }
            }
        }

        if (hasBags) {
            System.out.println("Bags already seeded");
            return;
        }

        Category accessories = categoryRepository.findByCategoryName("Accessories").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Accessories").build())
        );

        Category bags = categoryRepository.findByCategoryName("Bags").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Bags").parent(accessories).build())
        );

        String[] images = {
            "bags1.jpg", "bags2.jpg", "bags3.jpg", "bags4.jpg", "bags5.jpg"
        };

        String[] names = {
            "Leather Tote Bag", "Canvas Backpack", "Crossbody Messenger Bag", 
            "Quilted Shoulder Bag", "Suede Bucket Bag"
        };

        String[] brands = {
            "Michael Kors", "Fjallraven", "Coach", "Chanel", "Mansur Gavriel"
        };

        for (int i = 0; i < images.length; i++) {
            String img = images[i];
            String name = names[i];
            String brand = brands[i];

            Product p = Product.builder()
                .slug(img.replace(".jpg", "") + "-" + UUID.randomUUID().toString().substring(0, 8))
                .name(name)
                .sku("BAGS-SKU-" + i)
                .salePrice(85.0 + (i * 20))
                .comparePrice(115.0 + (i * 20))
                .buyingPrice(50.0)
                .quantity(150)
                .shortDescription("Premium " + name)
                .description("Detailed description for " + name + " from " + brand)
                .productType(brand)
                .published(true)
                .disableOutOfStock(false)
                .rating(4.8 + (i % 2) * 0.1)
                .reviewCount(75 + i * 15)
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
                .category(bags)
                .build();

            productCategoryRepository.save(pc);
        }

        System.out.println("Seeded " + images.length + " bags products.");
    }
}
