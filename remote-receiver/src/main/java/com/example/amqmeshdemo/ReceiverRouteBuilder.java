package com.example.amqmeshdemo;

import org.apache.camel.Exchange;
import org.apache.camel.builder.RouteBuilder;
import org.springframework.stereotype.Component;

@Component
public class ReceiverRouteBuilder extends RouteBuilder {

    @Override
    public void configure() throws Exception {

        // Generate an order and send it to a random address
        from("timer:orders?period=5000")
                .id("generateOrdersRoute")
                .bean(MessageGenerator.class)
                .setHeader("DestinationAddress",
                        method(AddressRandomiser.class))
                .toD("amqp:queue:${header.DestinationAddress}?exchangePattern=InOnly")
                .to("metrics:counter:messages.generated")
                .log("Sent a message to ${header.DestinationAddress}");

        // Receive any orders via our incoming work queue
        from("amqp:queue:AppIncomingWorkQueue")
                .id("receiveOrdersRoute")
                .to("metrics:counter:messages.received")
                .log("Received a message!");

    }
}
