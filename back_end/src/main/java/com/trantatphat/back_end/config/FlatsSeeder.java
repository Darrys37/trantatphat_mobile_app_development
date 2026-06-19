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
@Order(5)
public class FlatsSeeder implements CommandLineRunner {

    private final ProductRepository productRepository;
    private final GalleryRepository galleryRepository;
    private final CategoryRepository categoryRepository;
    private final ProductCategoryRepository productCategoryRepository;

    @Override
    public void run(String... args) throws Exception {
        boolean hasFlats = false;
        for (Product p : productRepository.findAll()) {
            if (p.getName() != null && p.getName().toLowerCase().contains("flats")) {
                hasFlats = true;
                break;
            }
        }

        if (hasFlats) {
            System.out.println("Flats already seeded");
            return;
        }

        Category shoes = categoryRepository.findByCategoryName("Shoes").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Shoes").build())
        );

        Category flats = categoryRepository.findByCategoryName("Flats").orElseGet(() ->
                categoryRepository.save(Category.builder().categoryName("Flats").parent(shoes).build())
        );

        String[] images = {
            "flats1.jpg", "flats2.jpg", "flats3.jpg", "flats4.jpg", "flats5.jpg",
            "flats6.jpg", "flats7.jpg", "flats8.jpg", "flats9.jpg", "flats10.jpg"
        };

        String[] names = {
            "Classic Ballet Flats", "Pointed Toe Flats", "Suede Loafer Flats", 
            "Slingback Flats", "Bow Tie Flats", "Ankle Strap Flats", 
            "Leather Mules Flats", "T-Strap Flats", "Quilted Flats", "Metallic Slip-On Flats"
        };

        String[] brands = {
            "Tory Burch", "Sam Edelman", "Everlane", "Rothy's", "Clarks",
            "Cole Haan", "Chanel", "Gucci", "Steve Madden", "Nine West"
        };

        for (int i = 0; i < images.length; i++) {
            String img = images[i];
            String name = names[i];
            String brand = brands[i];

            Product p = Product.builder()
                .slug(img.replace(".jpg", "") + "-" + UUID.randomUUID().toString().substring(0, 8))
                .name(name)
                .sku("FLATS-SKU-" + i)
                .salePrice(50.0 + (i * 6))
                .comparePrice(80.0 + (i * 6))
                .buyingPrice(35.0)
                .quantity(120)
                .shortDescription("Premium " + name)
                .description("Detailed description for " + name + " from " + brand)
                .productType(brand)
                .published(true)
                .disableOutOfStock(false)
                .rating(4.6 + (i % 4) * 0.1)
                .reviewCount(30 + i * 2)
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
                .category(flats)
                .build();

            productCategoryRepository.save(pc);
        }

        System.out.println("Seeded " + images.length + " flats products.");
    }
}
