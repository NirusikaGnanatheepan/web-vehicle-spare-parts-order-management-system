package com.example.spareparts.controller;

import com.example.spareparts.model.Invoice;
import com.example.spareparts.service.InvoiceService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/payments")
public class PaymentController {
    private final InvoiceService invoiceService;
    public PaymentController(InvoiceService invoiceService) {
        this.invoiceService = invoiceService;
    }

    @GetMapping
    public String listPayments(@RequestParam(required = false) Long customerId, Model model) {
        if (customerId != null) {
            model.addAttribute("invoices", invoiceService.findByCustomer(customerId));
        } else {
            model.addAttribute("invoices", invoiceService.findAll());
        }
        return "check-payment";
    }

    @PostMapping("/mark-paid")
    public String markPaid(@RequestParam Long id) {
        var invOpt = invoiceService.findById(id);
        if (invOpt.isPresent()) {
            var inv = invOpt.get();
            inv.setPaymentStatus("PAID");
            inv.setPaymentDate(java.time.LocalDate.now());
            invoiceService.save(inv);
        }
        return "redirect:/payments";
    }
}
