package com.example.auth.controller;

import com.example.auth.entity.Card;
import com.example.auth.entity.CardItem;
import com.example.auth.entity.Customer;
import com.example.auth.entity.Product;
import com.example.auth.repository.CardItemRepository;
import com.example.auth.repository.CardRepository;
import com.example.auth.repository.CustomerRepository;
import com.example.auth.repository.ProductRepository;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.UUID;

@RestController
@RequestMapping("/shop/cart")
@RequiredArgsConstructor
@CrossOrigin
public class CardController {

    private final CardRepository cardRepository;
    private final CardItemRepository cardItemRepository;
    private final CustomerRepository customerRepository;
    private final ProductRepository productRepository;

    @GetMapping("/{customerId}")
    public ResponseEntity<CardResponse> getCart(@PathVariable UUID customerId) {
        return ResponseEntity.ok(new CardResponse(getOrCreateCard(customerId)));
    }

    @PostMapping("/{customerId}/items")
    public ResponseEntity<CardResponse> addItem(
            @PathVariable UUID customerId,
            @Valid @RequestBody AddToCardRequest req) {

        Card card = getOrCreateCard(customerId);

        Product product = productRepository.findById(req.getProductId())
                .orElseThrow(() -> new RuntimeException("Product not found: " + req.getProductId()));

        if (product.isDisable_out_of_stock() && product.getQuantity() <= 0) {
            return ResponseEntity.badRequest().build();
        }

        cardItemRepository.findByCardAndProductAndVariant(
                card.getId(), req.getProductId(),
                req.getSelected_size(), req.getSelected_color())
                .ifPresentOrElse(
                        existing -> {
                            existing.setQuantity(existing.getQuantity() + req.getQuantity());
                            cardItemRepository.save(existing);
                        },
                        () -> {
                            CardItem newItem = CardItem.builder()
                                    .card(card)
                                    .product(product)
                                    .quantity(req.getQuantity())
                                    .selected_size(req.getSelected_size())
                                    .selected_color(req.getSelected_color())
                                    .build();
                            cardItemRepository.save(newItem);
                        }
                );

        Card updated = cardRepository.findByCustomerIdWithItems(customerId).orElse(card);
        return ResponseEntity.ok(new CardResponse(updated));
    }

    @PutMapping("/{customerId}/items/{itemId}")
    public ResponseEntity<CardResponse> updateItem(
            @PathVariable UUID customerId,
            @PathVariable UUID itemId,
            @Valid @RequestBody UpdateCardItemRequest req) {

        CardItem item = cardItemRepository.findById(itemId)
                .orElseThrow(() -> new RuntimeException("Cart item not found"));

        if (req.getQuantity() <= 0) {
            cardItemRepository.delete(item);
        } else {
            item.setQuantity(req.getQuantity());
            cardItemRepository.save(item);
        }

        Card updated = cardRepository.findByCustomerIdWithItems(customerId)
                .orElseThrow(() -> new RuntimeException("Cart not found"));
        return ResponseEntity.ok(new CardResponse(updated));
    }

    @DeleteMapping("/{customerId}/items/{itemId}")
    public ResponseEntity<CardResponse> removeItem(
            @PathVariable UUID customerId,
            @PathVariable UUID itemId) {

        cardItemRepository.deleteById(itemId);

        Card updated = cardRepository.findByCustomerIdWithItems(customerId)
                .orElseThrow(() -> new RuntimeException("Cart not found"));
        return ResponseEntity.ok(new CardResponse(updated));
    }

    @DeleteMapping("/{customerId}")
    public ResponseEntity<Void> clearCart(@PathVariable UUID customerId) {
        cardRepository.findByCustomerId(customerId).ifPresent(card ->
                cardItemRepository.deleteByCardId(card.getId()));
        return ResponseEntity.noContent().build();
    }

    private Card getOrCreateCard(UUID customerId) {
        return cardRepository.findByCustomerIdWithItems(customerId)
                .orElseGet(() -> {
                    Customer customer = customerRepository.findById(customerId)
                            .orElseThrow(() -> new RuntimeException("Customer not found: " + customerId));
                    return cardRepository.save(Card.builder()
                            .customer(customer)
                            .items(new ArrayList<>())
                            .build());
                });
    }
}
