package com.xxxx.whiteboard;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.xxxx.whiteboard.mapper")
public class WhiteBoardApplication {

    public static void main(String[] args) {
        SpringApplication.run(WhiteBoardApplication.class, args);
    }

}
