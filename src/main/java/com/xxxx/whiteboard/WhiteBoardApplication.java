package com.xxxx.whiteboard;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.ServletComponentScan;

@SpringBootApplication
@MapperScan("com.xxxx.whiteboard.mapper")
@ServletComponentScan(basePackages = "com.xxxx.whiteboard.mqttConn.MQTTListener")
public class WhiteBoardApplication {

    public static void main(String[] args) {
        SpringApplication.run(WhiteBoardApplication.class, args);
    }

}
