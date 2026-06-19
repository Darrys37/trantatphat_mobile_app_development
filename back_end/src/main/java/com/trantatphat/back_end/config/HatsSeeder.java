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
@Order(14)
public class HatsSeeder implements CommandLineRunner {

    private final ProductRepository productRepository;
    private final GalleryRepository galleryRepository;
    private final CategoryRepository categoryRepository;
    private final ProductCategoryRepository productCategoryRepository;

    @Override
    public void run(String... args) throws Exception {
        boolean hasHats = false;
        Category hatsOpt = categoryRepository.findByCategoryName("Hats").orElse(null);
        if (hatsOpt != null) {
            for (ProductCategory pc : productCategoryRepository.findAll()) {
                if (pc.getCategory().getId().equals(hatsOpt.getId())) {
                    hasHats = true;
                    break;
                }
            }
        }

        if (hasHats) {
            System.out.println("Hats already seeded");
            return;
        }

        Category accessories = categoryRepository.findByCategoryName("Accessories").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Accessories").build())
        );

        Category hats = categoryRepository.findByCategoryName("Hats").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Hats").parent(accessories).build())
        );

        String[] images = {
            "hats.jpg", "hats2.jpg", "hats3.jpg", "hats4.jpg", "hats5.jpg"
        };

        String[] names = {
            "Classic Fedora", "Straw Sun Hat", "Cotton Baseball Cap", 
            "Wool Beanie", "Wide Brim Panama Hat"
        };

        String[] brands = {
            "Borsalino", "Brixton", "New Era", "Carhartt", "Polo Ralph Lauren"
        };

        for (int i = 0; i < images.length; i++) {
            String img = images[i];
            String name = names[i];
            String brand = brands[i];

            Product p = Product.builder()
                .slug(img.replace(".jpg", "") + "-" + UUID.randomUUID().toString().substring(0, 8))
                .name(name)
                .sku("HATS-SKU-" + i)
                .salePrice(45.0 + (i * 15))
                .comparePrice(60.0 + (i * 15))
                .buyingPrice(20.0)
                .quantity(200)
                .shortDescription("Premium " + name)
                .description("Detailed description for " + name + " from " + brand)
                .productType(brand)
                .published(true)
                .disableOutOfStock(false)
                .rating(4.6 + (i % 3) * 0.1)
                .reviewCount(150 + i * 20)
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
                .category(hats)
                .build();

            productCategoryRepository.save(pc);
        }

        System.out.println("Seeded " + images.length + " hats products.");
    }
}
