package com.trantatphat.back_end.config;

import com.trantatphat.back_end.entity.Product;
import com.trantatphat.back_end.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.core.annotation.Order;

import java.util.List;
import java.util.Random;

@Component
@RequiredArgsConstructor
@Order(3)
public class RenameProductsRunner implements CommandLineRunner {

    private final ProductRepository productRepository;

    @Override
    public void run(String... args) throws Exception {
        List<Product> products = productRepository.findAll();
        boolean needsRename = false;
        
        for (Product p : products) {
            if (p.getName().contains("Fashionable") || p.getName().contains("Exclusive") || p.getName().contains("Premium")) {
                needsRename = true;
                break;
            }
        }
        
        if (!needsRename) {
            return;
        }

        String[] adjectives = {"Midnight", "Velvet", "Radiant", "Classic", "Urban", "Bohemian", "Chic", "Graceful", "Ethereal", "Signature", "Luxe", "Essential", "Breeze", "Autumn", "Spring", "Summer", "Winter", "Golden", "Silver", "Crimson"};
        String[] styles = {"A-Line", "Oversized", "Fitted", "Pleated", "Cropped", "Wrap", "Ribbed", "Tailored", "Flowy", "Structured", "Draped", "Asymmetric", "Sleeveless", "Long Sleeve", "V-Neck", "Turtleneck"};
        
        Random rand = new Random();
        
        for (Product p : products) {
            if (p.getSku() != null && p.getSku().startsWith("SHOE-")) {
                continue;
            }
            
            String image = p.getSlug() != null ? p.getSlug().toLowerCase() : "";
            
            String type = "Apparel";
            if (image.contains("dress")) type = "Dress";
            else if (image.contains("blouse") || image.contains("top")) type = "Blouse";
            else if (image.contains("knit")) type = "Knit Sweater";
            else if (image.contains("blazer")) type = "Blazer";
            else if (image.contains("skirt")) type = "Skirt";
            else if (image.contains("pant")) type = "Trousers";
            else if (image.contains("outerwear") || image.contains("coat")) type = "Trench Coat";
            else if (image.contains("bag")) type = "Leather Handbag";
            else if (image.contains("shirt")) type = "Shirt";
            else if (image.contains("wc")) type = "Designer Top";

            String adj = adjectives[rand.nextInt(adjectives.length)];
            String style = styles[rand.nextInt(styles.length)];
            
            String newName = adj + " " + style + " " + type;
            p.setName(newName);
            
            productRepository.save(p);
        }
        
        System.out.println("Successfully renamed products to have unique identities.");
    }
}
