package com.example.amqmeshdemo;

import org.apache.activemq.jms.pool.PooledConnectionFactory;
import org.apache.camel.component.amqp.AMQPComponent;
import org.apache.qpid.jms.JmsConnectionFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
 
/**
 * The Spring-boot main class.
 */
@SpringBootApplication
public class Application {

	public static void main(String[] args) {
		SpringApplication.run(Application.class, args);
	}

	@Bean(name = "amqp-component")
	AMQPComponent amqpComponent(AMQPConfiguration config) {
		JmsConnectionFactory qpid = new JmsConnectionFactory(
				config.getUsername(), config.getPassword(),
				config.getUrl());

		PooledConnectionFactory factory = new PooledConnectionFactory();
		factory.setConnectionFactory(qpid);

		return new AMQPComponent(factory);
	}

}
