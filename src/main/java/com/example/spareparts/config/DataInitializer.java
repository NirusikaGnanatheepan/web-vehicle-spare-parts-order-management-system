package com.example.spareparts.config;

import com.example.spareparts.model.Customer;
import com.example.spareparts.service.CustomerService;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class DataInitializer {

    @Bean
    CommandLineRunner seedInitialData(CustomerService customerService) {
        return args -> {
            if (customerService.findAll().isEmpty()) {
                Customer customer = new Customer();
                customer.setName("John Doe");
                customer.setEmail("john.doe@example.com");
                customer.setContactNumber("+1-555-0100");
                customer.setAddress("123 Main Street, New York, NY");
                customerService.save(customer);
            }
        };
    }
}


