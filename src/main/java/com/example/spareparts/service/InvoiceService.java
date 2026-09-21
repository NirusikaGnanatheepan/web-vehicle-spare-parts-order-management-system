package com.example.spareparts.service;

import com.example.spareparts.model.Invoice;
import com.example.spareparts.repository.InvoiceRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class InvoiceService {
    private final InvoiceRepository invoiceRepository;
    public InvoiceService(InvoiceRepository invoiceRepository) {
        this.invoiceRepository = invoiceRepository;
    }

    public List<Invoice> findAll() { return invoiceRepository.findAll(); }
    public List<Invoice> findByCustomer(Long customerId) { return invoiceRepository.findByCustomerId(customerId); }
    public Optional<Invoice> findById(Long id) { return invoiceRepository.findById(id); }
    public Invoice save(Invoice invoice) { return invoiceRepository.save(invoice); }
}
