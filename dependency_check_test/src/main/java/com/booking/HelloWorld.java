package com.booking;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class HelloWorld {
    protected static final Logger logger = LogManager.getLogger();

    public static void main(String[] args) {
        logger.info("hello world");
    }
}
