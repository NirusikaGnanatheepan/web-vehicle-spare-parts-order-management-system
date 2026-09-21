package com.example.spareparts.service;

import com.example.spareparts.model.PurchaseOrder;
import com.example.spareparts.repository.OrderRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class OrderService {
    private final OrderRepository orderRepository;
    public OrderService(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    public List<PurchaseOrder> findAll() { return orderRepository.findAll(); }
    public List<PurchaseOrder> findByCustomer(Long customerId) { return orderRepository.findByCustomerId(customerId); }
    public Optional<PurchaseOrder> findById(Long id) { return orderRepository.findById(id); }
    public PurchaseOrder save(PurchaseOrder order) { return orderRepository.save(order); }
}
