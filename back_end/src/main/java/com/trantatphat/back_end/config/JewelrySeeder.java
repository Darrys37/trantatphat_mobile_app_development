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
@Order(12)
public class JewelrySeeder implements CommandLineRunner {

    private final ProductRepository productRepository;
    private final GalleryRepository galleryRepository;
    private final CategoryRepository categoryRepository;
    private final ProductCategoryRepository productCategoryRepository;

    @Override
    public void run(String... args) throws Exception {
        boolean hasJewelry = false;
        Category jewelryOpt = categoryRepository.findByCategoryName("Jewelry").orElse(null);
        if (jewelryOpt != null) {
            for (ProductCategory pc : productCategoryRepository.findAll()) {
                if (pc.getCategory().getId().equals(jewelryOpt.getId())) {
                    hasJewelry = true;
                    break;
                }
            }
        }

        if (hasJewelry) {
            System.out.println("Jewelry already seeded");
            return;
        }

        Category accessories = categoryRepository.findByCategoryName("Accessories").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Accessories").build())
        );

        Category jewelry = categoryRepository.findByCategoryName("Jewelry").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Jewelry").parent(accessories).build())
        );

        String[] images = {
            "jewelry1.jpg", "jewelry2.jpg", "jewelry3.jpg", "jewelry4.jpg", "jewelry5.jpg"
        };

        String[] names = {
            "Diamond Pendant Necklace", "Gold Hoop Earrings", "Silver Tennis Bracelet", 
            "Pearl Drop Earrings", "Sapphire Ring"
        };

        String[] brands = {
            "Tiffany & Co.", "Cartier", "Swarovski", "Pandora", "Bvlgari"
        };

        for (int i = 0; i < images.length; i++) {
            String img = images[i];
            String name = names[i];
            String brand = brands[i];

            Product p = Product.builder()
                .slug(img.replace(".jpg", "") + "-" + UUID.randomUUID().toString().substring(0, 8))
                .name(name)
                .sku("JEWELRY-SKU-" + i)
                .salePrice(250.0 + (i * 100))
                .comparePrice(300.0 + (i * 100))
                .buyingPrice(120.0)
                .quantity(30)
                .shortDescription("Premium " + name)
                .description("Detailed description for " + name + " from " + brand)
                .productType(brand)
                .published(true)
                .disableOutOfStock(false)
                .rating(4.8 + (i % 2) * 0.1)
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
                .category(jewelry)
                .build();

            productCategoryRepository.save(pc);
        }

        System.out.println("Seeded " + images.length + " jewelry products.");
    }
}
