package com.cpifp.alanturing.holamundo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import com.cpifp.alanturing.holamundo.domain.Hello;

@RestController
public class Greeting {

    @GetMapping("hola")
    public Hello sayHello() {
        return new Hello("Hola, mi amigo");
    }
    
}
