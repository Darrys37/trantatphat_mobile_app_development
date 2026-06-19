package com.trantatphat.back_end.service;

import com.trantatphat.back_end.entity.Cart;
import com.trantatphat.back_end.entity.CartItem;
import com.trantatphat.back_end.entity.Product;
import com.trantatphat.back_end.entity.User;
import com.trantatphat.back_end.payload.request.CartItemRequest;
import com.trantatphat.back_end.payload.response.CartItemResponse;
import com.trantatphat.back_end.repository.CartItemRepository;
import com.trantatphat.back_end.repository.CartRepository;
import com.trantatphat.back_end.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CartService {

    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final ProductRepository productRepository;

    @Transactional
    public Cart getOrCreateCart(User user) {
        java.util.List<Cart> carts = cartRepository.findByUser(user);
        if (carts != null && !carts.isEmpty()) {
            if (carts.size() > 1) {
                Cart mainCart = carts.get(0);
                for (int i = 1; i < carts.size(); i++) {
                    Cart duplicate = carts.get(i);
                    java.util.List<CartItem> duplicateItems = cartItemRepository.findByCart(duplicate);
                    for (CartItem item : duplicateItems) {
                        item.setCart(mainCart);
                        cartItemRepository.save(item);
                    }
                    cartRepository.delete(duplicate);
                }
                return mainCart;
            }
            return carts.get(0);
        }
        Cart newCart = Cart.builder().user(user).build();
        return cartRepository.save(newCart);
    }

    @Transactional
    public List<CartItemResponse> getCartItems(User user) {
        Cart cart = getOrCreateCart(user);
        List<CartItem> items = cartItemRepository.findByCart(cart);
        return items.stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    @Transactional
    public CartItemResponse addToCart(User user, CartItemRequest request) {
        Cart cart = getOrCreateCart(user);
        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new RuntimeException("Product not found"));

        Optional<CartItem> existingItem = cartItemRepository.findByCartAndProductAndColorAndSize(
                cart, product, request.getColor(), request.getSize());

        CartItem item;
        if (existingItem.isPresent()) {
            item = existingItem.get();
            item.setQuantity(item.getQuantity() + request.getQuantity());
        } else {
            item = CartItem.builder()
                    .cart(cart)
                    .product(product)
                    .color(request.getColor())
                    .size(request.getSize())
                    .quantity(request.getQuantity())
                    .build();
        }
        
        CartItem savedItem = cartItemRepository.save(item);
        return mapToResponse(savedItem);
    }

    @Transactional
    public CartItemResponse updateQuantity(User user, UUID cartItemId, int quantity) {
        Cart cart = getOrCreateCart(user);
        CartItem item = cartItemRepository.findById(cartItemId)
                .orElseThrow(() -> new RuntimeException("Cart item not found"));
        
        if (!item.getCart().getId().equals(cart.getId())) {
            throw new RuntimeException("Unauthorized to modify this cart item");
        }

        item.setQuantity(quantity);
        CartItem savedItem = cartItemRepository.save(item);
        return mapToResponse(savedItem);
    }

    @Transactional
    public void removeFromCart(User user, UUID cartItemId) {
        Cart cart = getOrCreateCart(user);
        CartItem item = cartItemRepository.findById(cartItemId)
                .orElseThrow(() -> new RuntimeException("Cart item not found"));
        
        if (!item.getCart().getId().equals(cart.getId())) {
            throw new RuntimeException("Unauthorized to modify this cart item");
        }
        
        cartItemRepository.delete(item);
    }

    private CartItemResponse mapToResponse(CartItem item) {
        Product p = item.getProduct();
        return CartItemResponse.builder()
                .id(item.getId())
                .productId(p.getId())
                .productName(p.getName())
                .productImageUrl(p.getImageUrl())
                .price(p.getSalePrice() != null ? p.getSalePrice() : 0.0)
                .color(item.getColor())
                .size(item.getSize())
                .quantity(item.getQuantity())
                .build();
    }
}
