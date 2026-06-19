package com.trantatphat.back_end.service;

import com.trantatphat.back_end.entity.DeliveryMethod;
import com.trantatphat.back_end.entity.PaymentCard;
import com.trantatphat.back_end.entity.User;
import com.trantatphat.back_end.entity.UserAddress;
import com.trantatphat.back_end.entity.Cart;
import com.trantatphat.back_end.entity.CartItem;
import com.trantatphat.back_end.entity.Order;
import com.trantatphat.back_end.entity.OrderItem;
import com.trantatphat.back_end.entity.OrderStatus;
import com.trantatphat.back_end.repository.*;
import com.trantatphat.back_end.dto.SubmitOrderRequest;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CheckoutService {

    private final UserAddressRepository userAddressRepository;
    private final PaymentCardRepository paymentCardRepository;
    private final DeliveryMethodRepository deliveryMethodRepository;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final OrderStatusRepository orderStatusRepository;
    private final ProductRepository productRepository;

    @PostConstruct
    @Transactional
    public void initMockData() {
        if (deliveryMethodRepository.count() == 0) {
            deliveryMethodRepository.save(DeliveryMethod.builder().name("FedEx").duration("2-3 days").price(15.0).logoUrl("fedex.png").build());
            deliveryMethodRepository.save(DeliveryMethod.builder().name("USPS.COM").duration("2-3 days").price(10.0).logoUrl("usps.png").build());
            deliveryMethodRepository.save(DeliveryMethod.builder().name("DHL").duration("2-3 days").price(20.0).logoUrl("dhl.png").build());
        }
        
        clearProcessingOrders();
    }

    @Transactional
    public synchronized void initUserMockDataIfNeeded(User user) {
        if (userAddressRepository.findByUser(user).isEmpty()) {
            userAddressRepository.save(UserAddress.builder()
                    .user(user)
                    .fullName("Jane Doe")
                    .address("3 Newbridge Court")
                    .city("Chino Hills")
                    .state("CA")
                    .zipCode("91709")
                    .country("United States")
                    .isDefault(true)
                    .build());
        }

        if (paymentCardRepository.findByUser(user).isEmpty()) {
            paymentCardRepository.save(PaymentCard.builder()
                    .user(user)
                    .cardHolderName("Jennyfer Doe")
                    .cardNumber("**** **** **** 3947")
                    .expiryDate("05/23")
                    .brand("Mastercard")
                    .isDefault(true)
                    .build());
            paymentCardRepository.save(PaymentCard.builder()
                    .user(user)
                    .cardHolderName("Jennyfer Doe")
                    .cardNumber("**** **** **** 4546")
                    .expiryDate("11/22")
                    .brand("Visa")
                    .isDefault(false)
                    .build());
        }

        if (orderRepository.findByUserOrderByCreatedAtDesc(user).isEmpty()) {
            OrderStatus deliveredStatus = orderStatusRepository.findByStatusName("Delivered")
                    .orElseGet(() -> orderStatusRepository.save(OrderStatus.builder().statusName("Delivered").color("green").build()));

            List<com.trantatphat.back_end.entity.Product> allProducts = productRepository.findAll();
            if (!allProducts.isEmpty()) {
                for (int i = 0; i < 3; i++) {
                    Order order = Order.builder()
                            .id(UUID.randomUUID().toString())
                            .user(user)
                            .shippingAddress("3 Newbridge Court, Chino Hills, CA 91709, United States")
                            .paymentMethod("Mastercard ending in 3947")
                            .deliveryMethod("FedEx")
                            .totalAmount(112.0)
                            .orderStatus(deliveredStatus)
                            .createdAt(java.time.ZonedDateTime.now().minusDays(10 + i * 5))
                            .build();
                    order = orderRepository.save(order);

                    OrderItem orderItem = OrderItem.builder()
                            .order(order)
                            .product(allProducts.get(0))
                            .price(112.0)
                            .quantity(3)
                            .color("Black")
                            .size("M")
                            .build();
                    orderItemRepository.save(orderItem);
                }
            }
        }
    }

    @Transactional
    public List<UserAddress> getUserAddresses(User user) {
        initUserMockDataIfNeeded(user);
        return userAddressRepository.findByUser(user);
    }

    @Transactional
    public List<PaymentCard> getPaymentCards(User user) {
        initUserMockDataIfNeeded(user);
        return paymentCardRepository.findByUser(user);
    }

    public List<DeliveryMethod> getDeliveryMethods() {
        return deliveryMethodRepository.findAll();
    }

    @Transactional
    public PaymentCard addPaymentCard(User user, PaymentCard card) {
        if (card.getIsDefault() != null && card.getIsDefault()) {
            clearDefaultPaymentCard(user);
        } else if (paymentCardRepository.findByUser(user).isEmpty()) {
            card.setIsDefault(true);
        } else {
            card.setIsDefault(false);
        }
        card.setUser(user);
        return paymentCardRepository.save(card);
    }

    @Transactional
    public void setDefaultPaymentCard(User user, UUID cardId) {
        clearDefaultPaymentCard(user);
        PaymentCard card = paymentCardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));
        if (card.getUser().getId().equals(user.getId())) {
            card.setIsDefault(true);
            paymentCardRepository.save(card);
        }
    }

    @Transactional
    public void deletePaymentCard(User user, UUID cardId) {
        PaymentCard card = paymentCardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Card not found"));
        if (!card.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized");
        }
        paymentCardRepository.delete(card);
    }

    private void clearDefaultPaymentCard(User user) {
        List<PaymentCard> cards = paymentCardRepository.findByUser(user);
        for (PaymentCard c : cards) {
            if (c.getIsDefault() != null && c.getIsDefault()) {
                c.setIsDefault(false);
                paymentCardRepository.save(c);
            }
        }
    }

    @Transactional
    public UserAddress addUserAddress(User user, UserAddress address) {
        if (address.getIsDefault() != null && address.getIsDefault()) {
            clearDefaultAddress(user);
        } else if (userAddressRepository.findByUser(user).isEmpty()) {
            address.setIsDefault(true);
        } else {
            address.setIsDefault(false);
        }
        address.setUser(user);
        return userAddressRepository.save(address);
    }

    @Transactional
    public UserAddress updateUserAddress(User user, UUID addressId, UserAddress updatedAddress) {
        UserAddress existing = userAddressRepository.findById(addressId)
                .orElseThrow(() -> new RuntimeException("Address not found"));
        if (!existing.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized");
        }
        
        existing.setFullName(updatedAddress.getFullName());
        existing.setAddress(updatedAddress.getAddress());
        existing.setCity(updatedAddress.getCity());
        existing.setState(updatedAddress.getState());
        existing.setZipCode(updatedAddress.getZipCode());
        existing.setCountry(updatedAddress.getCountry());
        
        if (updatedAddress.getIsDefault() != null && updatedAddress.getIsDefault() && (existing.getIsDefault() == null || !existing.getIsDefault())) {
            clearDefaultAddress(user);
            existing.setIsDefault(true);
        }
        
        return userAddressRepository.save(existing);
    }

    @Transactional
    public void setDefaultUserAddress(User user, UUID addressId) {
        clearDefaultAddress(user);
        UserAddress address = userAddressRepository.findById(addressId)
                .orElseThrow(() -> new RuntimeException("Address not found"));
        if (address.getUser().getId().equals(user.getId())) {
            address.setIsDefault(true);
            userAddressRepository.save(address);
        }
    }

    private void clearDefaultAddress(User user) {
        List<UserAddress> addresses = userAddressRepository.findByUser(user);
        for (UserAddress a : addresses) {
            if (a.getIsDefault() != null && a.getIsDefault()) {
                a.setIsDefault(false);
                userAddressRepository.save(a);
            }
        }
    }

    @Transactional
    public void deleteUserAddress(User user, UUID addressId) {
        UserAddress existing = userAddressRepository.findById(addressId)
                .orElseThrow(() -> new RuntimeException("Address not found"));
        if (!existing.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized");
        }
        userAddressRepository.delete(existing);
    }

    @Transactional
    public void submitOrder(User user, SubmitOrderRequest request) {
        UserAddress address = userAddressRepository.findByUser(user).stream()
                .filter(a -> a.getIsDefault() != null && a.getIsDefault())
                .findFirst()
                .orElseThrow(() -> new RuntimeException("No default shipping address found"));

        String paymentMethodName = request.getPaymentMethod();
        if (paymentMethodName == null || paymentMethodName.isEmpty()) {
            PaymentCard card = paymentCardRepository.findByUser(user).stream()
                    .filter(c -> c.getIsDefault() != null && c.getIsDefault())
                    .findFirst()
                    .orElseThrow(() -> new RuntimeException("No default payment method found"));
            paymentMethodName = card.getBrand() + " ending in " + card.getCardNumber().substring(card.getCardNumber().length() - 4);
        } else if (!"Cash on Delivery".equals(paymentMethodName)) {
            // Frontend sent a specific card number or name, just use it
            // Or look it up if we want to be strict. Here we'll just use what frontend sends.
            if (paymentMethodName.contains("Credit Card")) {
                PaymentCard card = paymentCardRepository.findByUser(user).stream()
                        .filter(c -> c.getIsDefault() != null && c.getIsDefault())
                        .findFirst()
                        .orElseThrow(() -> new RuntimeException("No default payment method found"));
                paymentMethodName = card.getBrand() + " ending in " + card.getCardNumber().substring(card.getCardNumber().length() - 4);
            }
        }

        DeliveryMethod deliveryMethod = deliveryMethodRepository.findById(request.getDeliveryMethodId())
                .orElseThrow(() -> new RuntimeException("Delivery method not found"));

        Cart cart = cartRepository.findFirstByUser(user).orElseThrow(() -> new RuntimeException("Cart not found"));
        List<CartItem> cartItems = cartItemRepository.findByCart(cart);

        if (cartItems.isEmpty()) {
            throw new RuntimeException("Cart is empty");
        }

        Order order = Order.builder()
                .id(UUID.randomUUID().toString())
                .user(user)
                .shippingAddress(address.getFullName() + ", " + address.getAddress() + ", " + address.getCity() + ", " + address.getState() + " " + address.getZipCode() + ", " + address.getCountry())
                .paymentMethod(paymentMethodName)
                .deliveryMethod(deliveryMethod.getName())
                .totalAmount(request.getOrderTotal())
                .coupon(cart.getCoupon())
                .build();

        order = orderRepository.save(order);

        for (CartItem item : cartItems) {
            OrderItem orderItem = OrderItem.builder()
                    .order(order)
                    .product(item.getProduct())
                    .price(item.getProduct().getSalePrice())
                    .quantity(item.getQuantity())
                    .color(item.getColor())
                    .size(item.getSize())
                    .build();
            orderItemRepository.save(orderItem);
        }

        cartItemRepository.deleteByCart(cart);
        cart.setCoupon(null);
        cartRepository.save(cart);
    }

    @Transactional
    public List<com.trantatphat.back_end.dto.OrderDto> getUserOrders(User user) {
        List<Order> orders = orderRepository.findByUserOrderByCreatedAtDesc(user);
        return orders.stream().map(order -> {
            List<OrderItem> items = orderItemRepository.findByOrder(order);
            int quantity = items.stream().mapToInt(OrderItem::getQuantity).sum();
            
            String statusName = "Processing";
            if (order.getOrderStatus() != null) {
                statusName = order.getOrderStatus().getStatusName();
            }
            
            java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("dd-MM-yyyy");
            String dateStr = order.getCreatedAt() != null ? order.getCreatedAt().format(formatter) : "";
            
            return com.trantatphat.back_end.dto.OrderDto.builder()
                    .id(order.getId())
                    .trackingNumber("IW" + order.getId().substring(0, Math.min(order.getId().length(), 10)).toUpperCase())
                    .quantity(quantity)
                    .totalAmount(order.getTotalAmount())
                    .date(dateStr)
                    .status(statusName)
                    .build();
        }).toList();
    }

    @Transactional
    public com.trantatphat.back_end.dto.OrderDetailsDto getOrderDetails(User user, String orderId) {
        Order order = orderRepository.findById(orderId).orElseThrow(() -> new RuntimeException("Order not found"));
        if (!order.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized");
        }

        List<OrderItem> items = orderItemRepository.findByOrder(order);
        int quantity = items.stream().mapToInt(OrderItem::getQuantity).sum();
        
        String statusName = "Processing";
        if (order.getOrderStatus() != null) {
            statusName = order.getOrderStatus().getStatusName();
        }
        
        java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("dd-MM-yyyy");
        String dateStr = order.getCreatedAt() != null ? order.getCreatedAt().format(formatter) : "";
        
        List<com.trantatphat.back_end.dto.OrderItemDto> itemDtos = items.stream().map(item -> {
            String brandName = item.getProduct().getProductType() != null ? item.getProduct().getProductType() : "Mango";
            return com.trantatphat.back_end.dto.OrderItemDto.builder()
                    .productId(item.getProduct().getId().toString())
                    .image(item.getProduct().getImageUrl())
                    .productName(item.getProduct().getName())
                    .brand(brandName)
                    .color(item.getColor() != null ? item.getColor() : "Gray")
                    .size(item.getSize() != null ? item.getSize() : "L")
                    .units(item.getQuantity())
                    .price(item.getPrice())
                    .build();
        }).toList();

        String discountText = "";
        if (order.getCoupon() != null) {
            int discountInt = order.getCoupon().getDiscountValue() != null ? order.getCoupon().getDiscountValue().intValue() : 0;
            discountText = discountInt + "%, " + order.getCoupon().getCode();
        } else {
            discountText = "No discount applied";
        }

        return com.trantatphat.back_end.dto.OrderDetailsDto.builder()
                .id(order.getId())
                // Assuming tracking number is somewhat derived
                .trackingNumber("IW" + order.getId().substring(0, Math.min(order.getId().length(), 10)).toUpperCase())
                .quantity(quantity)
                .totalAmount(order.getTotalAmount())
                .date(dateStr)
                .status(statusName)
                .shippingAddress(order.getShippingAddress() != null ? order.getShippingAddress() : "N/A")
                .paymentMethod(order.getPaymentMethod() != null ? order.getPaymentMethod() : "N/A")
                .deliveryMethod(order.getDeliveryMethod() != null ? order.getDeliveryMethod() : "N/A")
                .discount(discountText)
                .items(itemDtos)
                .build();
    }

    @Transactional
    public void cancelOrder(User user, String orderId) {
        Order order = orderRepository.findById(orderId).orElseThrow(() -> new RuntimeException("Order not found"));
        if (!order.getUser().getId().equals(user.getId())) {
            throw new RuntimeException("Unauthorized");
        }
        if (order.getOrderStatus() != null && "Cancelled".equals(order.getOrderStatus().getStatusName())) {
            throw new RuntimeException("Order is already cancelled");
        }

        OrderStatus cancelledStatus = orderStatusRepository.findByStatusName("Cancelled")
                .orElseGet(() -> {
                    OrderStatus newStatus = OrderStatus.builder()
                            .statusName("Cancelled")
                            .color("Red")
                            .privacy("Public")
                            .build();
                    return orderStatusRepository.save(newStatus);
                });

        order.setOrderStatus(cancelledStatus);
        orderRepository.save(order);
    }

    @Transactional
    public void clearProcessingOrders() {
        List<Order> orders = orderRepository.findAllWithStatus();
        for (Order order : orders) {
            String status = order.getOrderStatus() != null ? order.getOrderStatus().getStatusName() : "Processing";
            if ("Processing".equalsIgnoreCase(status)) {
                List<OrderItem> items = orderItemRepository.findByOrder(order);
                orderItemRepository.deleteAll(items);
                orderRepository.delete(order);
            }
        }
    }
}
