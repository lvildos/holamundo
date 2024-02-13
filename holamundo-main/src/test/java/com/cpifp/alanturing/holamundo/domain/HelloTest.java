package com.cpifp.alanturing.holamundo.domain;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

public class HelloTest {
    @Test
    void testGetGreeting() {
        // Arrange
        Hello saludo = new Hello("APRENDE A PROBAR");
        // Act
        String actual = saludo.getGreeting();
        // Assert
        assertEquals("APRENDE A PROBAR",actual);
    }

    @Test
    void testSetGreeting() {

    }
}
