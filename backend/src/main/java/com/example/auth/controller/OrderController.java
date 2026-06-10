package com.example.auth.controller;

import com.example.auth.entity.*;
import com.example.auth.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.*;

@RestController
@RequestMapping("/shop/orders")
@RequiredArgsConstructor
@CrossOrigin
public class OrderController {

    private final OrderRepository orderRepository;
    private final CustomerRepository customerRepository;
    private final ProductRepository productRepository;
    private final OrderStatusRepository orderStatusRepository;
    private final CouponRepository couponRepository;
    private final CustomerAddressRepository customerAddressRepository;

    @GetMapping("/customer/{customerId}")
    public ResponseEntity<List<Order>> getByCustomer(@PathVariable UUID customerId) {
        return ResponseEntity.ok(orderRepository.findByCustomerIdOrderByCreated_atDesc(customerId));
    }

    @GetMapping("/{orderId}")
    public ResponseEntity<?> getById(@PathVariable String orderId) {
        return orderRepository.findById(orderId)
                .<ResponseEntity<?>>map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<?> createOrder(@RequestBody Map<String, Object> body) {
        UUID customerId = UUID.fromString((String) body.get("customerId"));
        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new RuntimeException("Customer not found"));

        CustomerAddress address = null;
        if (body.containsKey("addressId")) {
            UUID addressId = UUID.fromString((String) body.get("addressId"));
            address = customerAddressRepository.findById(addressId).orElse(null);
        }

        Coupon coupon = null;
        if (body.containsKey("couponCode")) {
            coupon = couponRepository.findByCode((String) body.get("couponCode")).orElse(null);
        }

        OrderStatus pendingStatus = orderStatusRepository.findByStatusName("Pending").orElse(null);
        String orderId = "ORD-" + System.currentTimeMillis();

        Order order = Order.builder()
                .id(orderId)
                .customer(customer)
                .coupon(coupon)
                .orderStatus(pendingStatus)
                .shippingAddress(address)
                .items(new ArrayList<>())
                .build();

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> rawItems = (List<Map<String, Object>>) body.get("items");
        BigDecimal total = BigDecimal.ZERO;

        if (rawItems != null) {
            for (Map<String, Object> raw : rawItems) {
                UUID productId = UUID.fromString((String) raw.get("productId"));
                Product product = productRepository.findById(productId)
                        .orElseThrow(() -> new RuntimeException("Product not found: " + productId));

                int qty = raw.containsKey("quantity") ? ((Number) raw.get("quantity")).intValue() : 1;

                OrderItem item = OrderItem.builder()
                        .order(order)
                        .product(product)
                        .price(product.getSale_price())
                        .quantity(qty)
                        .selected_variant((String) raw.getOrDefault("selectedVariant", null))
                        .build();

                order.getItems().add(item);
                total = total.add(product.getSale_price().multiply(BigDecimal.valueOf(qty)));
            }
        }

        order.setTotal_amount(total);
        return ResponseEntity.ok(orderRepository.save(order));
    }
}
