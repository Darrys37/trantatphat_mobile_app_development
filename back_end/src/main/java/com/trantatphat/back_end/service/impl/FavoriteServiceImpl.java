package com.trantatphat.back_end.service.impl;

import com.trantatphat.back_end.entity.Favorite;
import com.trantatphat.back_end.entity.Product;
import com.trantatphat.back_end.entity.User;
import com.trantatphat.back_end.repository.FavoriteRepository;
import com.trantatphat.back_end.repository.ProductRepository;
import com.trantatphat.back_end.service.FavoriteService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FavoriteServiceImpl implements FavoriteService {

    private final FavoriteRepository favoriteRepository;
    private final ProductRepository productRepository;

    @Override
    public List<Product> getUserFavorites(User user) {
        List<Favorite> favorites = favoriteRepository.findByUserOrderByCreatedAtDesc(user);
        return favorites.stream()
                .map(Favorite::getProduct)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void addFavorite(User user, UUID productId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        
        if (!favoriteRepository.existsByUserAndProduct(user, product)) {
            Favorite favorite = Favorite.builder()
                    .user(user)
                    .product(product)
                    .build();
            favoriteRepository.save(favorite);
        }
    }

    @Override
    @Transactional
    public void removeFavorite(User user, UUID productId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        
        favoriteRepository.deleteByUserAndProduct(user, product);
    }

    @Override
    public boolean isFavorited(User user, UUID productId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        
        return favoriteRepository.existsByUserAndProduct(user, product);
    }
}
