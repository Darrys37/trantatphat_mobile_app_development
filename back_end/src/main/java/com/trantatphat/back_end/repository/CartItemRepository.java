package com.trantatphat.back_end.repository;

import com.trantatphat.back_end.entity.Cart;
import com.trantatphat.back_end.entity.CartItem;
import com.trantatphat.back_end.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface CartItemRepository extends JpaRepository<CartItem, UUID> {
    List<CartItem> findByCartOrderByIdAsc(Cart cart);
    Optional<CartItem> findByCartAndProductAndColorAndSize(Cart cart, Product product, String color, String size);
    
    // Default method for backward compatibility
    default List<CartItem> findByCart(Cart cart) {
        return findByCartOrderByIdAsc(cart);
    }
    void deleteByCart(Cart cart);
}
