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
@Order(7)
public class SlippersSeeder implements CommandLineRunner {

    private final ProductRepository productRepository;
    private final GalleryRepository galleryRepository;
    private final CategoryRepository categoryRepository;
    private final ProductCategoryRepository productCategoryRepository;

    @Override
    public void run(String... args) throws Exception {
        boolean hasSlippers = false;
        Category slippersOpt = categoryRepository.findByCategoryName("Slippers").orElse(null);
        if (slippersOpt != null) {
            for (ProductCategory pc : productCategoryRepository.findAll()) {
                if (pc.getCategory().getId().equals(slippersOpt.getId())) {
                    hasSlippers = true;
                    break;
                }
            }
        }

        if (hasSlippers) {
            System.out.println("Slippers already seeded");
            return;
        }

        Category shoes = categoryRepository.findByCategoryName("Shoes").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Shoes").build())
        );

        Category slippers = categoryRepository.findByCategoryName("Slippers").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Slippers").parent(shoes).build())
        );

        String[] images = {
            "slippers1.jpg", "slippers2.jpg", "slipper3.jpg", "slipper4.jpg", "slipper5.jpg"
        };

        String[] names = {
            "Plush Indoor Slippers", "Fleece-Lined Slippers", "Memory Foam Slip-Ons", 
            "Faux Fur Slippers", "Cozy House Slippers"
        };

        String[] brands = {
            "UGG", "Acorn", "Dearfoams", "Minnetonka", "Sorel"
        };

        for (int i = 0; i < images.length; i++) {
            String img = images[i];
            String name = names[i];
            String brand = brands[i];

            Product p = Product.builder()
                .slug(img.replace(".jpg", "") + "-" + UUID.randomUUID().toString().substring(0, 8))
                .name(name)
                .sku("SLIPPERS-SKU-" + i)
                .salePrice(30.0 + (i * 5))
                .comparePrice(45.0 + (i * 5))
                .buyingPrice(15.0)
                .quantity(200)
                .shortDescription("Premium " + name)
                .description("Detailed description for " + name + " from " + brand)
                .productType(brand)
                .published(true)
                .disableOutOfStock(false)
                .rating(4.5 + (i % 3) * 0.1)
                .reviewCount(50 + i * 5)
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
                .category(slippers)
                .build();

            productCategoryRepository.save(pc);
        }

        System.out.println("Seeded " + images.length + " slippers products.");
    }
}
