package com.example.auth.controller;

import com.example.auth.entity.Customer;
import com.example.auth.entity.CustomerAddress;
import com.example.auth.repository.CustomerAddressRepository;
import com.example.auth.repository.CustomerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * API địa chỉ giao hàng của khách.
 *
 * GET    /shop/addresses/{customerId}          → danh sách địa chỉ
 * POST   /shop/addresses/{customerId}          → thêm địa chỉ
 * PUT    /shop/addresses/{addressId}           → cập nhật
 * DELETE /shop/addresses/{addressId}           → xoá
 */
@RestController
@RequestMapping("/shop/addresses")
@RequiredArgsConstructor
@CrossOrigin
public class CustomerAddressController {

    private final CustomerAddressRepository addressRepository;
    private final CustomerRepository customerRepository;

    @GetMapping("/{customerId}")
    public ResponseEntity<List<CustomerAddress>> getAll(@PathVariable UUID customerId) {
        return ResponseEntity.ok(addressRepository.findByCustomerId(customerId));
    }

    @PostMapping("/{customerId}")
    public ResponseEntity<?> add(
            @PathVariable UUID customerId,
            @RequestBody Map<String, String> body) {

        Customer customer = customerRepository.findById(customerId)
                .orElseThrow(() -> new RuntimeException("Customer not found"));

        CustomerAddress address = CustomerAddress.builder()
                .customer(customer)
                .address_line1(body.get("address_line1"))
                .address_line2(body.getOrDefault("address_line2", null))
                .phone_number(body.get("phone_number"))
                .dial_code(body.getOrDefault("dial_code", "+84"))
                .country(body.getOrDefault("country", "Vietnam"))
                .postal_code(body.getOrDefault("postal_code", ""))
                .city(body.get("city"))
                .is_default(Boolean.parseBoolean(body.getOrDefault("is_default", "false")))
                .build();

        return ResponseEntity.ok(addressRepository.save(address));
    }

    @DeleteMapping("/{addressId}")
    public ResponseEntity<?> delete(@PathVariable UUID addressId) {
        if (!addressRepository.existsById(addressId)) return ResponseEntity.notFound().build();
        addressRepository.deleteById(addressId);
        return ResponseEntity.ok().build();
    }
}
