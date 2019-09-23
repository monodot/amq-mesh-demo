package com.example.amqmeshdemo;

import com.codahale.metrics.MetricRegistry;
import com.codahale.metrics.servlets.MetricsServlet;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Arrays;
import java.util.LinkedHashSet;

@Configuration
public class MetricsConfiguration {

    @Bean
    public MetricRegistry metricRegistry() {
        return new MetricRegistry();
    }

    @Bean
    public MetricsServlet metricsServlet(MetricRegistry registry) {
        return new MetricsServlet(registry);
    }

    @Bean
    public ServletRegistrationBean servletRegistrationBean(MetricsServlet metricsServlet) {
        ServletRegistrationBean servletRegistrationBean = new ServletRegistrationBean();
        servletRegistrationBean.setName("metrics-servlet");
        servletRegistrationBean.setServlet(metricsServlet);
        servletRegistrationBean.setUrlMappings(
                new LinkedHashSet<String>(Arrays.asList("/metrics/*")));
        return servletRegistrationBean;
    }

}
