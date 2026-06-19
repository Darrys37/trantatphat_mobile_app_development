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
@Order(11)
public class WatchesSeeder implements CommandLineRunner {

    private final ProductRepository productRepository;
    private final GalleryRepository galleryRepository;
    private final CategoryRepository categoryRepository;
    private final ProductCategoryRepository productCategoryRepository;

    @Override
    public void run(String... args) throws Exception {
        boolean hasWatches = false;
        Category watchesOpt = categoryRepository.findByCategoryName("Watches").orElse(null);
        if (watchesOpt != null) {
            for (ProductCategory pc : productCategoryRepository.findAll()) {
                if (pc.getCategory().getId().equals(watchesOpt.getId())) {
                    hasWatches = true;
                    break;
                }
            }
        }

        if (hasWatches) {
            System.out.println("Watches already seeded");
            return;
        }

        Category accessories = categoryRepository.findByCategoryName("Accessories").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Accessories").build())
        );

        Category watches = categoryRepository.findByCategoryName("Watches").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Watches").parent(accessories).build())
        );

        String[] images = {
            "watch1.jpg", "watch2.jpg", "watch3.jpg", "watch4.jpg", "watch5.jpg"
        };

        String[] names = {
            "Classic Analog Watch", "Digital Sports Watch", "Luxury Chronograph", 
            "Minimalist Mesh Watch", "Smart Fitness Watch"
        };

        String[] brands = {
            "Rolex", "Casio", "Omega", "Daniel Wellington", "Apple"
        };

        for (int i = 0; i < images.length; i++) {
            String img = images[i];
            String name = names[i];
            String brand = brands[i];

            Product p = Product.builder()
                .slug(img.replace(".jpg", "") + "-" + UUID.randomUUID().toString().substring(0, 8))
                .name(name)
                .sku("WATCHES-SKU-" + i)
                .salePrice(150.0 + (i * 50))
                .comparePrice(200.0 + (i * 50))
                .buyingPrice(80.0)
                .quantity(50)
                .shortDescription("Premium " + name)
                .description("Detailed description for " + name + " from " + brand)
                .productType(brand)
                .published(true)
                .disableOutOfStock(false)
                .rating(4.7 + (i % 3) * 0.1)
                .reviewCount(50 + i * 10)
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
                .category(watches)
                .build();

            productCategoryRepository.save(pc);
        }

        System.out.println("Seeded " + images.length + " watches products.");
    }
}
