package com.trantatphat.back_end.service;

import com.trantatphat.back_end.entity.Product;
import com.trantatphat.back_end.entity.User;

import java.util.List;
import java.util.UUID;

public interface FavoriteService {
    List<Product> getUserFavorites(User user);
    void addFavorite(User user, UUID productId);
    void removeFavorite(User user, UUID productId);
    boolean isFavorited(User user, UUID productId);
}
