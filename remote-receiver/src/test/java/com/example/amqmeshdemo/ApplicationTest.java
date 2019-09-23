package com.example.amqmeshdemo;

import org.apache.camel.RoutesBuilder;
import org.apache.camel.builder.NotifyBuilder;
import org.apache.camel.test.junit4.CamelTestSupport;
import org.junit.Ignore;
import org.junit.Test;

public class ApplicationTest extends CamelTestSupport {

    @Override
    public String isMockEndpointsAndSkip() {
        return "amqp:*";
    }

    @Override
    protected RoutesBuilder createRouteBuilder() throws Exception {
        return new ReceiverRouteBuilder();
    }

    @Test
    @Ignore
    private void testOneMessageProduced() {
        NotifyBuilder notify = new NotifyBuilder(context).whenDone(1).create();

    }

}