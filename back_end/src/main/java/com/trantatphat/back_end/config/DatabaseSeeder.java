package com.trantatphat.back_end.config;

import com.trantatphat.back_end.entity.Category;
import com.trantatphat.back_end.entity.Gallery;
import com.trantatphat.back_end.entity.Product;
import com.trantatphat.back_end.entity.ProductCategory;
import com.trantatphat.back_end.entity.Tag;
import com.trantatphat.back_end.repository.CategoryRepository;
import com.trantatphat.back_end.repository.GalleryRepository;
import com.trantatphat.back_end.repository.ProductCategoryRepository;
import com.trantatphat.back_end.repository.ProductRepository;
import com.trantatphat.back_end.repository.ProductReviewRepository;
import com.trantatphat.back_end.repository.ReviewGalleryRepository;
import com.trantatphat.back_end.repository.TagRepository;
import com.trantatphat.back_end.repository.UserRepository;
import com.trantatphat.back_end.entity.User;
import com.trantatphat.back_end.entity.ProductReview;
import com.trantatphat.back_end.entity.ReviewGallery;
import com.trantatphat.back_end.entity.Provider;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.core.annotation.Order;

import java.util.UUID;
import java.util.Set;
import java.util.List;
import java.util.Random;
import java.util.ArrayList;
import java.time.ZonedDateTime;

@Component
@RequiredArgsConstructor
@Order(1)
public class DatabaseSeeder implements CommandLineRunner {

    private final ProductRepository productRepository;
    private final TagRepository tagRepository;
    private final GalleryRepository galleryRepository;
    private final CategoryRepository categoryRepository;
    private final ProductCategoryRepository productCategoryRepository;
    private final UserRepository userRepository;
    private final ProductReviewRepository productReviewRepository;
    private final ReviewGalleryRepository reviewGalleryRepository;

    @Override
    public void run(String... args) throws Exception {
        if (productRepository.count() > 0) {
            System.out.println("Database already seeded");
            return;
        }

        Tag newTag = tagRepository.save(Tag.builder().name("NEW").build());
        Tag saleTag = tagRepository.save(Tag.builder().name("SALE").build());

        // Create Main Categories (for future hierarchical use, though currently flat)
        Category tops = categoryRepository.save(Category.builder().categoryName("Tops").build());
        Category shirts = categoryRepository.save(Category.builder().categoryName("Shirts & Blouses").build());
        Category cardigans = categoryRepository.save(Category.builder().categoryName("Cardigans & Sweaters").build());
        Category knitwear = categoryRepository.save(Category.builder().categoryName("Knitwear").build());
        Category outerwear = categoryRepository.save(Category.builder().categoryName("Outerwear").build());
        Category blazers = categoryRepository.save(Category.builder().categoryName("Blazers").build());
        Category pants = categoryRepository.save(Category.builder().categoryName("Pants").build());
        Category jeans = categoryRepository.save(Category.builder().categoryName("Jeans").build());
        Category shorts = categoryRepository.save(Category.builder().categoryName("Shorts").build());
        Category skirts = categoryRepository.save(Category.builder().categoryName("Skirts").build());
        Category dresses = categoryRepository.save(Category.builder().categoryName("Dresses").build());
        
        // These are kept empty per user request
        Category shoes = categoryRepository.save(Category.builder().categoryName("Shoes").build());
        Category accessories = categoryRepository.save(Category.builder().categoryName("Accessories").build());

        String[] images = {
            "wc1.jpg", "wc2.jpg", "wc3.jpg", "wc4.jpg", "wc5.jpg", "wc6.jpg", 
            "blouse4.jpg", "blouse5.jpg", "blouse6.jpg", "blouses1.jpg", "blouses2.jpg", "blouses3.jpg", "blouses7.jpg", 
            "wc15.jpg", "wc16.jpg", "wc17.jpg", "wc18.jpg", "wc19.jpg", "wc20.jpg", 
            "dress1.jpg", "dress2.jpg", "dress3.jpg", "dress4.jpg", "dress5.jpg", "dress6.jpg", "blazer6.jpg", 
            "blazer7.jpg", "blazer8.jpg", "blazer9.jpg", "wc7.jpg", "new_dress_1.png", "new_dress_2.png", 
            "womens_fashion_1.png", "womens_fashion_2.png", "womens_fashion_3.png", "womens_fashion_4.png", "new_skirt_1.png", 
            "new_skirt_2.png", "knitwear6.jpg", "pants1.jpg", "womens_fashion_5.png", "womens_fashion_6.png", "womens_fashion_7.png", 
            "womens_fashion_8.png", "womens_fashion_9.png", "red_blouse.png", "sale_bag_1.png", "outerwear6.jpg", "womens_fashion_10.png", 
            "knitwear7.jpg", "knitwear8.jpg", "knitwear9.jpg", "dress7.jpg", "dress8.jpg", 
            "outerwear7.jpg", "outerwear8.jpg", "wc8.jpg", "wc9.jpg", "wc10.jpg", "wc11.jpg", 
            "skirt1.jpg", "skirt2.jpg", "skirt3.jpg", "skirt4.jpg", "skirt5.jpg", "sportdress.jpg", "blazer10.jpg", 
            "wc12.jpg", "wc13.jpg", "wc14.jpg", "womens_top_casual.png", "womens_top_floral.png", 
            "womens_top_silk.png", "cardigans1.jpg", "cardigans2.jpg", "cardigans3.jpg", "cardigans4.jpg", 
            "cardigans5.jpg", "cardigans6.jpg", "cardigans7.jpg", "cardigans8.jpg", "cardigans9.jpg", "cardigans10.jpg",
            "wjeans.jpg", "wjeans2.jpg", "wjeans3.jpg", "wjeans4.jpg", "wjeans5.jpg",
            "wjeans6.jpg", "wjeans7.jpg", "wjeans8.jpg", "wjeans9.jpg", "wjeans10.jpg",
            "knitwear10.jpg", "knitwear11.jpg", "knitwear12.jpg", "knitwear13.jpg", "knitwear14.jpg", "knitwear15.jpg",
            "pants4.jpg", "pants5.jpg", "pants6.jpg", "pants7.jpg", "pants8.jpg", "pants9.jpg", "pants10.jpg",
            "short1.jpg", "short2.jpg", "short3.jpg", "shorts4.jpg", "short5.jpg", "short6.jpg", "short7.jpg", "short8.jpg", "short9.jpg", "short10.jpg",
            "outerwear3.jpg", "outerwear4.jpg", "outerwear5.jpg", "outerwear9.jpg", "outerwear10.jpg", "outerwear11.jpg", "outerwear12.jpg", "outerwear13.jpg",
            "blazer2.jpg", "blazer5.jpg", "blazer11.jpg", "blazer12.jpg", "blazer13.jpg", "blazer14.jpg", "blazer15.jpg",
            "skirt6.jpg", "skirt7.jpg", "skirt8.jpg", "skirt9.jpg", "skirt10.jpg"
        };

        if (productRepository.count() == 0) {
            for (int i = 0; i < images.length; i++) {
                String img = images[i];
                String name = formatProductName(img);
                String brand = formatProductBrand(img);
                
                Product p = Product.builder()
                    .slug(img.replace(".jpg", "").replace(".png", "") + "-" + UUID.randomUUID().toString().substring(0, 8))
                    .name(name)
                    .sku("SKU-" + i)
                    .salePrice(50.0 + (i % 50))
                    .comparePrice(i % 2 == 0 ? null : 60.0 + (i % 50))
                    .buyingPrice(30.0)
                    .quantity(100)
                    .shortDescription("This is " + name)
                    .description("Detailed description for " + name)
                    .productType(brand)
                    .published(true)
                    .disableOutOfStock(false)
                    .rating(4.5)
                    .reviewCount(10 + i)
                    .tags(Set.of(i % 2 == 0 ? newTag : saleTag))
                    .build();
                
                productRepository.save(p);

                Gallery g = Gallery.builder()
                    .product(p)
                    .image("assets/" + img)
                    .placeholder("assets/" + img)
                    .isThumbnail(true)
                    .build();
                
                galleryRepository.save(g);

                Category targetCategory = tops; // default
                String lowerImg = img.toLowerCase();
                if (lowerImg.contains("dress")) {
                    targetCategory = dresses;
                } else if (lowerImg.contains("skirt")) {
                    targetCategory = skirts;
                } else if (lowerImg.contains("blazer")) {
                    targetCategory = blazers;
                } else if (lowerImg.contains("knitwear")) {
                    targetCategory = knitwear;
                } else if (lowerImg.contains("outerwear")) {
                    targetCategory = outerwear;
                } else if (lowerImg.contains("pants")) {
                    targetCategory = pants;
                } else if (lowerImg.contains("blouse")) {
                    targetCategory = shirts;
                } else if (lowerImg.contains("top")) {
                    targetCategory = tops;
                } else if (lowerImg.contains("jeans")) {
                    targetCategory = jeans;
                } else if (lowerImg.contains("short")) {
                    targetCategory = shorts;
                } else if (lowerImg.contains("sweater") || lowerImg.contains("cardigan")) {
                    targetCategory = cardigans;
                } else if (lowerImg.contains("bag")) {
                    // Though user said keep accessories empty, we have a bag image. 
                    // Let's just put it in accessories or Tops depending on strictness.
                    // User said "shoes và accessories tạm thời để trống", so let's put bag in Tops to keep Accessories empty.
                    targetCategory = tops;
                }

                ProductCategory pc = ProductCategory.builder()
                    .product(p)
                    .category(targetCategory)
                    .build();
                
                productCategoryRepository.save(pc);
            }
        }

        // Seed Users
        List<User> users = new ArrayList<>();
        String[] userNames = {"Helene Moore", "Kate Doe", "Kim Shine", "Matilda Brown", "John Smith", "Jane Austen"};
        String[] avatars = {
            "https://i.pravatar.cc/150?img=1", "https://i.pravatar.cc/150?img=2", 
            "https://i.pravatar.cc/150?img=3", "https://i.pravatar.cc/150?img=4",
            "https://i.pravatar.cc/150?img=5", "https://i.pravatar.cc/150?img=6"
        };
        for (int i = 0; i < userNames.length; i++) {
            User u = new User();
            u.setName(userNames[i]);
            u.setEmail("user" + i + "@example.com");
            u.setPassword("password");
            u.setFirstName(userNames[i].split(" ")[0]);
            u.setLastName(userNames[i].split(" ")[1]);
            u.setImage(avatars[i]);
            u.setProvider(Provider.LOCAL);
            userRepository.save(u);
            users.add(u);
        }

        // Seed Reviews
        List<Product> products = productRepository.findAll();
        Random rand = new Random(42);
        for (Product p : products) {
            int numReviews = 3 + rand.nextInt(10); // 3 to 12 reviews
            double totalRating = 0;
            for (int i = 0; i < numReviews; i++) {
                User u = users.get(rand.nextInt(users.size()));
                double rating = 3.0 + rand.nextInt(3); // 3, 4, 5
                totalRating += rating;
                
                ProductReview review = ProductReview.builder()
                    .product(p)
                    .user(u)
                    .rating(rating)
                    .content("I loved this product so much as soon as I tried it on I knew I had to buy it in another color. Highly recommended!")
                    .build();
                productReviewRepository.save(review);

                // Add 2 photos to about 30% of reviews
                if (rand.nextDouble() < 0.3) {
                    reviewGalleryRepository.save(ReviewGallery.builder()
                        .review(review)
                        .imageUrl("https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80")
                        .build());
                    reviewGalleryRepository.save(ReviewGallery.builder()
                        .review(review)
                        .imageUrl("https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80")
                        .build());
                }
            }
            p.setReviewCount(numReviews);
            p.setRating(Math.round((totalRating / numReviews) * 10.0) / 10.0);
            productRepository.save(p);
        }

        System.out.println("Seeded " + images.length + " products, categories, users, and reviews.");
    }

    private String formatProductBrand(String filename) {
        if (filename.contains("cardigans")) {
            String[] brands = {"Zara", "H&M", "Mango", "Gucci", "Chanel", "Prada", "Dior", "Louis Vuitton", "Burberry", "Versace"};
            try {
                int index = Integer.parseInt(filename.replace("cardigans", "").replace(".jpg", "")) - 1;
                return brands[index % brands.length];
            } catch (Exception e) {
                return "Zara";
            }
        } else if (filename.contains("wjeans")) {
            String[] brands = {"Levi's", "Diesel", "Calvin Klein", "Guess", "Tommy Hilfiger", "Wrangler", "Lee", "True Religion", "G-Star RAW", "Balenciaga"};
            try {
                String numStr = filename.replace("wjeans", "").replace(".jpg", "");
                int index = numStr.isEmpty() ? 0 : Integer.parseInt(numStr) - 1;
                return brands[index % brands.length];
            } catch (Exception e) {
                return "Levi's";
            }
        } else if (filename.contains("knitwear")) {
            String[] brands = {"Uniqlo", "Ralph Lauren", "Tommy Hilfiger", "Massimo Dutti", "Everlane", "Madewell", "J.Crew", "COS", "Aritzia", "Reiss"};
            try {
                String numStr = filename.replace("knitwear", "").replace(".jpg", "");
                int index = numStr.isEmpty() ? 0 : Integer.parseInt(numStr) - 1;
                return brands[index % brands.length];
            } catch (Exception e) {
                return "Uniqlo";
            }
        } else if (filename.contains("pants")) {
            String[] brands = {"Dickies", "Carhartt", "Lululemon", "Nike", "Adidas", "Puma", "Under Armour", "ZARA", "Mango", "H&M"};
            try {
                String numStr = filename.replace("pants", "").replace(".jpg", "");
                int index = numStr.isEmpty() ? 0 : Integer.parseInt(numStr) - 1;
                return brands[index % brands.length];
            } catch (Exception e) {
                return "ZARA";
            }
        } else if (filename.contains("short")) {
            String[] brands = {"Vans", "Hollister", "American Eagle", "Gap", "Old Navy", "PacSun", "Roxy", "Billabong", "Volcom", "O'Neill"};
            try {
                String numStr = filename.replace("shorts", "").replace("short", "").replace(".jpg", "");
                int index = numStr.isEmpty() ? 0 : Integer.parseInt(numStr) - 1;
                return brands[index % brands.length];
            } catch (Exception e) {
                return "Vans";
            }
        } else if (filename.contains("outerwear")) {
            String[] brands = {"The North Face", "Patagonia", "Columbia", "Arc'teryx", "Moncler", "Canada Goose", "Marmot", "Salomon", "Helly Hansen", "Burburry"};
            try {
                String numStr = filename.replace("outerwear", "").replace(".jpg", "");
                int index = numStr.isEmpty() ? 0 : Integer.parseInt(numStr) - 1;
                return brands[index % brands.length];
            } catch (Exception e) {
                return "The North Face";
            }
        } else if (filename.contains("blazer")) {
            String[] brands = {"Armani", "Hugo Boss", "Tommy Hilfiger", "Calvin Klein", "Ralph Lauren", "Saint Laurent", "Gucci", "Givenchy", "Balmain", "Tom Ford"};
            try {
                String numStr = filename.replace("blazer", "").replace(".jpg", "");
                int index = numStr.isEmpty() ? 0 : Integer.parseInt(numStr) - 1;
                return brands[index % brands.length];
            } catch (Exception e) {
                return "Armani";
            }
        } else if (filename.contains("skirt")) {
            String[] brands = {"Miu Miu", "Dior", "Chanel", "Fendi", "Valentino", "Versace", "Prada", "Burberry", "Chloe", "Alexander McQueen"};
            try {
                String numStr = filename.replace("new_skirt_", "").replace("skirt", "").replace(".jpg", "").replace(".png", "");
                int index = numStr.isEmpty() ? 0 : Integer.parseInt(numStr) - 1;
                return brands[index % brands.length];
            } catch (Exception e) {
                return "Miu Miu";
            }
        }
        return "Mango";
    }

    private String formatProductName(String filename) {
        if (filename.contains("cardigans")) {
            String[] names = {
                "Classic Knit Cardigan", "Oversized Wool Sweater", "V-Neck Cashmere Cardigan", 
                "Chunky Cable Knit Sweater", "Ribbed Crop Cardigan", "Turtleneck Pullover", 
                "Fuzzy Mohair Cardigan", "Striped Cotton Sweater", "Button-Up Long Cardigan", "Wrap Belted Sweater"
            };
            try {
                int index = Integer.parseInt(filename.replace("cardigans", "").replace(".jpg", "")) - 1;
                return names[index % names.length];
            } catch (Exception e) {
                return "Fashion Cardigan";
            }
        } else if (filename.contains("wjeans")) {
            String[] names = {
                "High-Waisted Skinny Jeans", "Classic Straight Leg Jeans", "Flared Denim Jeans", 
                "Vintage Bootcut Jeans", "Ripped Boyfriend Jeans", "Distressed Mom Jeans", 
                "Cropped Wide Leg Jeans", "Stretch Jeggings", "Low-Rise Flare Jeans", "Acid Wash Denim"
            };
            try {
                String numStr = filename.replace("wjeans", "").replace(".jpg", "");
                int index = numStr.isEmpty() ? 0 : Integer.parseInt(numStr) - 1;
                return names[index % names.length];
            } catch (Exception e) {
                return "Premium Women's Jeans";
            }
        } else if (filename.contains("knitwear")) {
            String[] names = {
                "Cozy Oversized Knitwear", "Ribbed Turtleneck Sweater", "Chunky Cable Knit", 
                "Soft Cashmere Blend", "Cropped Knit Jumper", "V-Neck Pullover", 
                "Relaxed Fit Sweater", "Fine Gauge Knit Top", "Mohair Blend Knitwear", "Textured Pattern Sweater"
            };
            try {
                String numStr = filename.replace("knitwear", "").replace(".jpg", "");
                int index = numStr.isEmpty() ? 0 : Integer.parseInt(numStr) - 1;
                return names[index % names.length];
            } catch (Exception e) {
                return "Premium Knitwear";
            }
        } else if (filename.contains("pants")) {
            String[] names = {
                "Classic Chino Pants", "High-Waisted Wide Leg Trousers", "Cargo Utility Pants", 
                "Tailored Slim Fit Pants", "Linen Summer Trousers", "Jogger Sweatpants", 
                "Faux Leather Trousers", "Pleated Front Pants", "Cropped Culottes", "Athletic Track Pants"
            };
            try {
                String numStr = filename.replace("pants", "").replace(".jpg", "");
                int index = numStr.isEmpty() ? 0 : Integer.parseInt(numStr) - 1;
                return names[index % names.length];
            } catch (Exception e) {
                return "Stylish Women's Pants";
            }
        } else if (filename.contains("short")) {
            String[] names = {
                "High-Rise Denim Shorts", "Linen Summer Shorts", "Athletic Running Shorts", 
                "Distressed Cutoff Shorts", "Bermuda Shorts", "Frayed Hem Shorts", 
                "Paperbag Waist Shorts", "Biker Shorts", "Cotton Lounge Shorts", "Floral Print Shorts"
            };
            try {
                String numStr = filename.replace("shorts", "").replace("short", "").replace(".jpg", "");
                int index = numStr.isEmpty() ? 0 : Integer.parseInt(numStr) - 1;
                return names[index % names.length];
            } catch (Exception e) {
                return "Casual Women's Shorts";
            }
        } else if (filename.contains("outerwear")) {
            String[] names = {
                "Waterproof Trekking Jacket", "Lightweight Windbreaker", "Insulated Winter Parka", 
                "Fleece Zip-Up Jacket", "Classic Trench Coat", "Quilted Puffer Jacket", 
                "Faux Fur Lined Coat", "Double Breasted Peacoat", "Heavyweight Parka Coat", "Hooded Rain Jacket"
            };
            try {
                String numStr = filename.replace("outerwear", "").replace(".jpg", "");
                int index = numStr.isEmpty() ? 0 : Integer.parseInt(numStr) - 1;
                return names[index % names.length];
            } catch (Exception e) {
                return "Premium Outerwear";
            }
        } else if (filename.contains("blazer")) {
            String[] names = {
                "Tailored Fit Blazer", "Double Breasted Blazer", "Casual Linen Blazer", 
                "Oversized Boyfriend Blazer", "Classic Wool Blazer", "Tweed Plaid Blazer", 
                "Velvet Evening Blazer", "Cropped Suit Blazer", "Slim Fit Navy Blazer", "Belted Safari Blazer"
            };
            try {
                String numStr = filename.replace("blazer", "").replace(".jpg", "");
                int index = numStr.isEmpty() ? 0 : Integer.parseInt(numStr) - 1;
                return names[index % names.length];
            } catch (Exception e) {
                return "Designer Women's Blazer";
            }
        } else if (filename.contains("skirt")) {
            String[] names = {
                "Pleated Mini Skirt", "A-Line Midi Skirt", "Denim Pencil Skirt", 
                "Floral Wrap Skirt", "Leather Maxi Skirt", "Tweed Mini Skirt", 
                "Silk Slip Skirt", "High-Waisted Ruffle Skirt", "Checkered Skort", "Satin Midi Skirt"
            };
            try {
                String numStr = filename.replace("new_skirt_", "").replace("skirt", "").replace(".jpg", "").replace(".png", "");
                int index = numStr.isEmpty() ? 0 : Integer.parseInt(numStr) - 1;
                return names[index % names.length];
            } catch (Exception e) {
                return "Stylish Women's Skirt";
            }
        }
        
        String baseName = filename.replace(".jpg", "").replace(".png", "").replace("_", " ");
        baseName = baseName.replaceAll("[0-9]", "").trim(); // remove numbers
        String[] words = baseName.split(" ");
        StringBuilder sb = new StringBuilder();
        for (String word : words) {
            if (word.length() > 0) {
                sb.append(Character.toUpperCase(word.charAt(0)));
                if (word.length() > 1) {
                    sb.append(word.substring(1).toLowerCase());
                }
                sb.append(" ");
            }
        }
        String formatted = sb.toString().trim();
        
        if (formatted.equalsIgnoreCase("Sale Item") || formatted.equalsIgnoreCase("Clothes") || formatted.equalsIgnoreCase("Streetcloth")) {
            formatted = "Trendy Fashion Apparel";
        }
        if (formatted.equalsIgnoreCase("Wc")) {
            formatted = "Women's Collection Exclusive";
        }

        // Add e-commerce flair based on keywords
        String lower = formatted.toLowerCase();
        if (lower.contains("blazer")) {
            return "Premium Women's " + formatted + " - Elegant Office Wear";
        } else if (lower.contains("blouse") || lower.contains("top")) {
            return "Casual " + formatted + " - Summer Collection 2024";
        } else if (lower.contains("dress") || lower.contains("skirt")) {
            return "Vintage " + formatted + " - Perfect for Parties";
        } else if (lower.contains("knitwear") || lower.contains("sweater") || lower.contains("pullover")) {
            return "Cozy Winter " + formatted + " - Warm & Soft";
        } else if (lower.contains("shirt") || lower.contains("tshirt")) {
            return "Classic 100% Cotton " + formatted + " - Regular Fit";
        } else if (lower.contains("bag")) {
            return "Luxury Designer " + formatted + " - Premium Leather";
        } else if (lower.contains("shoes")) {
            return "Comfortable " + formatted + " - Breathable Sneakers";
        } else if (lower.contains("outerwear") || lower.contains("jacket")) {
            return "Stylish " + formatted + " - Windproof Coat";
        } else if (lower.contains("pants")) {
            return "High-Waisted Straight " + formatted + " - Casual Fit";
        } else {
            return "Fashionable " + formatted + " - New Arrival";
        }
    }
}
