package com.example.spareparts.controller;

import com.example.spareparts.model.PurchaseOrder;
import com.example.spareparts.service.OrderService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/orders")
public class OrderController {
    private final OrderService orderService;
    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @GetMapping
    public String listOrders(@RequestParam(required = false) Long customerId, Model model) {
        if (customerId != null) {
            model.addAttribute("orders", orderService.findByCustomer(customerId));
        } else {
            model.addAttribute("orders", orderService.findAll());
        }
        return "view-orders";
    }

    @GetMapping("/edit/{id}")
    public String editOrder(@PathVariable("id") Long id, Model model) {
        var orderOpt = orderService.findById(id);
        if (orderOpt.isPresent()) {
            model.addAttribute("order", orderOpt.get());
            return "update-delivery";
        } else {
            return "redirect:/orders";
        }
    }

    @PostMapping("/update")
    public String updateDelivery(@ModelAttribute PurchaseOrder order) {
        var existing = orderService.findById(order.getId());
        if (existing.isPresent()) {
            var o = existing.get();
            o.setStatus(order.getStatus());
            o.setTrackingNumber(order.getTrackingNumber());
            orderService.save(o);
        }
        return "redirect:/orders";
    }
}
