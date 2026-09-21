package com.example.spareparts.controller;

import com.example.spareparts.model.Customer;
import com.example.spareparts.service.CustomerService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/customers")
public class CustomerController {
    private final CustomerService customerService;
    public CustomerController(CustomerService customerService) {
        this.customerService = customerService;
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        model.addAttribute("customers", customerService.findAll());
        return "customer-dashboard";
    }

    @GetMapping("/create")
    public String createForm(Model model) {
        model.addAttribute("customer", new Customer());
        return "customer-form";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute Customer customer) {
        customerService.save(customer);
        return "redirect:/customers/dashboard";
    }

    @GetMapping("/edit/{id}")
    public String edit(@PathVariable("id") Long id, Model model) {
        var customerOpt = customerService.findById(id);
        if (customerOpt.isPresent()) {
            model.addAttribute("customer", customerOpt.get());
            return "customer-form";
        }
        return "redirect:/customers/dashboard";
    }

    @PostMapping("/delete/{id}")
    public String delete(@PathVariable("id") Long id) {
        customerService.deleteById(id);
        return "redirect:/customers/dashboard";
    }
}
