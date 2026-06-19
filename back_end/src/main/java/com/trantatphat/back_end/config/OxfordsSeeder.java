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
@Order(9)
public class OxfordsSeeder implements CommandLineRunner {

    private final ProductRepository productRepository;
    private final GalleryRepository galleryRepository;
    private final CategoryRepository categoryRepository;
    private final ProductCategoryRepository productCategoryRepository;

    @Override
    public void run(String... args) throws Exception {
        boolean hasOxfords = false;
        Category oxfordsOpt = categoryRepository.findByCategoryName("Oxfords").orElse(null);
        if (oxfordsOpt != null) {
            for (ProductCategory pc : productCategoryRepository.findAll()) {
                if (pc.getCategory().getId().equals(oxfordsOpt.getId())) {
                    hasOxfords = true;
                    break;
                }
            }
        }

        if (hasOxfords) {
            System.out.println("Oxfords already seeded");
            return;
        }

        Category shoes = categoryRepository.findByCategoryName("Shoes").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Shoes").build())
        );

        Category oxfords = categoryRepository.findByCategoryName("Oxfords").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Oxfords").parent(shoes).build())
        );

        String[] images = {
            "oxfords1.jpg", "oxfords2.jpg", "oxfords3.jpg", "oxfords4.jpg", "oxfords5.jpg"
        };

        String[] names = {
            "Classic Leather Oxfords", "Suede Wingtip Oxfords", "Platform Oxfords", 
            "Two-Tone Saddle Oxfords", "Patent Leather Oxfords"
        };

        String[] brands = {
            "Clarks", "Cole Haan", "Dr. Martens", "Bass", "Steve Madden"
        };

        for (int i = 0; i < images.length; i++) {
            String img = images[i];
            String name = names[i];
            String brand = brands[i];

            Product p = Product.builder()
                .slug(img.replace(".jpg", "") + "-" + UUID.randomUUID().toString().substring(0, 8))
                .name(name)
                .sku("OXFORDS-SKU-" + i)
                .salePrice(70.0 + (i * 10))
                .comparePrice(95.0 + (i * 10))
                .buyingPrice(45.0)
                .quantity(120)
                .shortDescription("Premium " + name)
                .description("Detailed description for " + name + " from " + brand)
                .productType(brand)
                .published(true)
                .disableOutOfStock(false)
                .rating(4.7 + (i % 3) * 0.1)
                .reviewCount(40 + i * 8)
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
                .category(oxfords)
                .build();

            productCategoryRepository.save(pc);
        }

        System.out.println("Seeded " + images.length + " oxfords products.");
    }
}
