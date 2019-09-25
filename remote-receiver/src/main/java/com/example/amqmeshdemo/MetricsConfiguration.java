package com.example.amqmeshdemo;

import com.codahale.metrics.MetricRegistry;
import com.codahale.metrics.servlets.MetricsServlet;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MetricsConfiguration {

    @Bean
    public MetricRegistry metricRegistry() {
        return new MetricRegistry();
    }

    //
//    @Bean
//    public MetricsServlet metricsServlet(MetricRegistry registry) {
//        return new MetricsServlet(registry);
//    }

    @Bean
    public ServletRegistrationBean metricsServlet(MetricRegistry registry) {
        System.out.println("REGISTERING METRICS SERVLET");
        ServletRegistrationBean servlet = new ServletRegistrationBean(
                new MetricsServlet(registry), "/metrics/*");
        servlet.setName("metrics-servlet");

//        );
//        servletRegistrationBean.setName("metrics-servlet");
//        servletRegistrationBean.setServlet(metricsServlet);
//        servletRegistrationBean.setUrlMappings(
//                new LinkedHashSet<String>(Arrays.asList("/metrics/*")));
        return servlet;
    }

}
