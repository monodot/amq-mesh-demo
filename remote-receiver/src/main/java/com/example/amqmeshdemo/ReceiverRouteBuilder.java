package com.example.amqmeshdemo;

import org.apache.camel.Exchange;
import org.apache.camel.LoggingLevel;
import org.apache.camel.builder.RouteBuilder;
import org.springframework.stereotype.Component;

@Component
public class ReceiverRouteBuilder extends RouteBuilder {

    @Override
    public void configure() throws Exception {

        // Receive any orders via our incoming work queue
        from("amqp:queue:AppIncomingWorkQueue")
                .id("receiveOrdersRoute")
                .to("metrics:counter:messages.received")
                .log("Received a message!");

        // Send some test messages on request
        // Don't use this in production :)
        from("servlet:/send")
                .log("Sending ${header.count} test messages to ${header.address}")
                .bean(MessageGenerator.class)
                .loop(header("count"))
                    .toD("amqp:topic:${header.address}?exchangePattern=InOnly")
                    .to("metrics:counter:messages.generated")
                    .log(LoggingLevel.DEBUG, "Sent message to: ${header.address}")
                .end()
                .setBody(constant("OK"));

    }
}
