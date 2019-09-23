package com.example.amqmeshdemo;

import org.apache.camel.Exchange;
import org.apache.camel.Processor;
import org.springframework.stereotype.Component;

@Component
public class MessageGenerator {

    public String generate() {
        return "Hello world!";
    }
}
