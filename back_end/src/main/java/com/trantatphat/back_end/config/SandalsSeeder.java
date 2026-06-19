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
@Order(6)
public class SandalsSeeder implements CommandLineRunner {

    private final ProductRepository productRepository;
    private final GalleryRepository galleryRepository;
    private final CategoryRepository categoryRepository;
    private final ProductCategoryRepository productCategoryRepository;

    @Override
    public void run(String... args) throws Exception {
        boolean hasSandals = false;
        Category sandalsOpt = categoryRepository.findByCategoryName("Sandals").orElse(null);
        if (sandalsOpt != null) {
            for (ProductCategory pc : productCategoryRepository.findAll()) {
                if (pc.getCategory().getId().equals(sandalsOpt.getId())) {
                    hasSandals = true;
                    break;
                }
            }
        }

        if (hasSandals) {
            System.out.println("Sandals already seeded");
            return;
        }

        Category shoes = categoryRepository.findByCategoryName("Shoes").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Shoes").build())
        );

        Category sandals = categoryRepository.findByCategoryName("Sandals").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Sandals").parent(shoes).build())
        );

        String[] images = {
            "sandals1.jpg", "sandals2.jpg", "sandals3.jpg", "sandals4.jpg", "sandals5.jpg"
        };

        String[] names = {
            "Leather Strappy Sandals", "Platform Wedge Sandals", "Gladiator Lace-Up Sandals", 
            "Slide-On Beach Sandals", "Heeled Evening Sandals"
        };

        String[] brands = {
            "Birkenstock", "Teva", "Steve Madden", "Crocs", "Stuart Weitzman"
        };

        for (int i = 0; i < images.length; i++) {
            String img = images[i];
            String name = names[i];
            String brand = brands[i];

            Product p = Product.builder()
                .slug(img.replace(".jpg", "") + "-" + UUID.randomUUID().toString().substring(0, 8))
                .name(name)
                .sku("SANDALS-SKU-" + i)
                .salePrice(40.0 + (i * 5))
                .comparePrice(60.0 + (i * 5))
                .buyingPrice(25.0)
                .quantity(150)
                .shortDescription("Premium " + name)
                .description("Detailed description for " + name + " from " + brand)
                .productType(brand)
                .published(true)
                .disableOutOfStock(false)
                .rating(4.4 + (i % 3) * 0.1)
                .reviewCount(40 + i * 5)
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
                .category(sandals)
                .build();

            productCategoryRepository.save(pc);
        }

        System.out.println("Seeded " + images.length + " sandals products.");
    }
}
