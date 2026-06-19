package com.trantatphat.back_end;

import com.trantatphat.back_end.entity.Product;
import com.trantatphat.back_end.entity.Gallery;
import com.trantatphat.back_end.repository.ProductRepository;
import com.trantatphat.back_end.repository.GalleryRepository;
import com.trantatphat.back_end.repository.ProductReviewRepository;
import com.trantatphat.back_end.repository.ReviewGalleryRepository;
import com.trantatphat.back_end.repository.UserRepository;
import com.trantatphat.back_end.repository.PaymentCardRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Arrays;
import java.util.Random;

@Component
public class DataSeeder implements CommandLineRunner {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private GalleryRepository galleryRepository;

    @Autowired
    private ProductReviewRepository productReviewRepository;

    @Autowired
    private ReviewGalleryRepository reviewGalleryRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PaymentCardRepository paymentCardRepository;

    @Override
    @Transactional
    public void run(String... args) throws Exception {
        System.out.println("====== STARTING DATA SEEDER TO UPDATE IMAGES ======");
        List<Product> products = productRepository.findAll();
        
        List<String> newImages = Arrays.asList(
            "assets/images/main_page_product_1.png",
            "assets/images/main_page_product_2.png",
            "assets/images/product_card_H&M.png",
            "assets/images/product_card_H&M1.png",
            "assets/images/catalog_1_blouse.png",
            "assets/images/catalog_1_pullover.png",
            "assets/images/catalog_1_shirt.png",
            "assets/images/catalog_1_T-shirt.png",
            "assets/images/catalog_2_blouse.png",
            "assets/images/catalog_2_t-shirt_spannish.png",
            "assets/images/favorites_longsleeve_violeta.png",
            "assets/images/favorites_shirt_lime.png",
            "assets/images/favorites_shirt_out_stock.png",
            "assets/images/favorites_t-shirt.png",
            "assets/images/my_bag_sport_dress.png",
            "assets/images/my_bag_t-shirt.png"
        );
        
        for (int i = 0; i < products.size(); i++) {
            Product p = products.get(i);
            String newImage = newImages.get(i % newImages.size());
            
            if (p.getGalleries() != null && !p.getGalleries().isEmpty()) {
                for (Gallery g : p.getGalleries()) {
                    g.setImage(newImage);
                    galleryRepository.save(g);
                }
            } else {
                Gallery g = new Gallery();
                g.setProduct(p);
                g.setImage(newImage);
                g.setPlaceholder("");
                g.setIsThumbnail(true);
                galleryRepository.save(g);
            }
        }
        
        System.out.println("====== DATA SEEDER FINISHED UPDATING IMAGES ======");

        System.out.println("====== STARTING DATA SEEDER TO UPDATE REVIEWS ======");
        List<com.trantatphat.back_end.entity.ProductReview> reviews = productReviewRepository.findAll();
        
        for (int i = 0; i < reviews.size(); i++) {
            com.trantatphat.back_end.entity.ProductReview r = reviews.get(i);
            
            // Delete old gallery
            reviewGalleryRepository.deleteByReviewId(r.getId());

            if (i % 3 == 0) {
                // Helene Moore
                r.getUser().setName("Helene Moore");
                r.getUser().setImage("assets/images/helene_moore.png");
                userRepository.save(r.getUser());
                r.setContent("The dress is great! Very classy and comfortable. It fit perfectly! I'm 5'7\" and 130 pounds. I am a 34B chest. This dress would be too long for those who are shorter but could be hemmed. I wouldn't recommend it for those big chested as I am smaller chested and it fit me perfectly. The underarms were not too wide and the dress was made well.");
            } else if (i % 3 == 1) {
                // Kim Shine
                r.getUser().setName("Kim Shine");
                r.getUser().setImage("assets/images/ratting_and_review-with_photo_kim_shine.png");
                userRepository.save(r.getUser());
                r.setContent("I loved this dress so much as soon as I tried it on I knew I had to buy it in another color. I am 5'3 about 155lbs and I carry all my weight in my upper body. When I put it on I felt like it thinned me out and I got so many compliments.");
                
                com.trantatphat.back_end.entity.ReviewGallery rg1 = new com.trantatphat.back_end.entity.ReviewGallery();
                rg1.setReview(r);
                rg1.setImageUrl("assets/images/ratting_and_review-with_photo_1.png");
                reviewGalleryRepository.save(rg1);

                com.trantatphat.back_end.entity.ReviewGallery rg2 = new com.trantatphat.back_end.entity.ReviewGallery();
                rg2.setReview(r);
                rg2.setImageUrl("assets/images/ratting_and_review-with_photo_2.png");
                reviewGalleryRepository.save(rg2);
            } else {
                // Matilda Brown
                r.getUser().setName("Matilda Brown");
                r.getUser().setImage("assets/images/ratting_and_review-with__maltida_brown.png");
                userRepository.save(r.getUser());
                r.setContent("I loved this dress so much as soon as I tried it on I knew I had to buy it in another color. I am 5'3 about 155lbs and I carry all my weight in my upper body. When I put it on I felt like it thinned me out and I got so many compliments.");

                com.trantatphat.back_end.entity.ReviewGallery rg3 = new com.trantatphat.back_end.entity.ReviewGallery();
                rg3.setReview(r);
                rg3.setImageUrl("assets/images/ratting_and_review-with_photo_3.png");
                reviewGalleryRepository.save(rg3);
            }

            productReviewRepository.save(r);
        }
        System.out.println("====== DATA SEEDER FINISHED UPDATING REVIEWS ======");
        
        System.out.println("====== CLEANING UP DUPLICATE PAYMENT CARDS ======");
        List<com.trantatphat.back_end.entity.User> users = userRepository.findAll();
        for(com.trantatphat.back_end.entity.User u : users) {
            List<com.trantatphat.back_end.entity.PaymentCard> cards = paymentCardRepository.findByUser(u);
            if(cards.size() > 2) {
                // Keep only the first two distinct cards, delete the rest
                java.util.Set<String> seenCardNumbers = new java.util.HashSet<>();
                for(com.trantatphat.back_end.entity.PaymentCard c : cards) {
                    if(!seenCardNumbers.contains(c.getCardNumber())) {
                        seenCardNumbers.add(c.getCardNumber());
                    } else {
                        paymentCardRepository.delete(c);
                    }
                }
            }
        }
        System.out.println("====== FINISHED CLEANING UP DUPLICATE PAYMENT CARDS ======");
    }
}
