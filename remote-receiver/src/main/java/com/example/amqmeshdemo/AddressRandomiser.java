package com.example.amqmeshdemo;

import org.springframework.stereotype.Component;

@Component
public class AddressRandomiser {

    public String getRandomAddress() {
        return "acme.logistics.sales";
    }

}
