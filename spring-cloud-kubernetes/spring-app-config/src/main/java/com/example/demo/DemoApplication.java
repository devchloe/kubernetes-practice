package com.example.demo;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class DemoApplication {

	public static void main(String[] args) {
		SpringApplication.run(DemoApplication.class, args);
	}

	@Value("${greeting.message}")
    private String greetingMessage;

    @Value("${hi}")
    private String hi;

    @RequestMapping("/")
    public String hello() {
        return greetingMessage;
    }

    @GetMapping("/hi")
    public String hi() {
        return hi;
    }
}
