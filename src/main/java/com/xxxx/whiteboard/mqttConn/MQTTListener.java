package com.xxxx.whiteboard.mqttConn;

import lombok.extern.slf4j.Slf4j;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.ApplicationListener;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

import javax.servlet.annotation.WebListener;

/**
 * 项目启动 监听主题
 * ContextRefreshedEvent 是指项目启动完毕
 *
 * @author fan yang
 * @since 2022/10/28
 */
@Slf4j
@Component
//@WebListener
public class MQTTListener implements ApplicationRunner {
    //public class MQTTListener implements ApplicationListener<ContextRefreshedEvent> {

    //private final MQTTConnect server;

    //@Autowired
    //public MQTTListener(MQTTConnect server) {
    //    this.server = server;
    //}

    //@Override
    //public void onApplicationEvent(ContextRefreshedEvent contextRefreshedEvent) {
    //
    //    try {
    //        server.sub("com/iot/init");
    //        server.pubS("com/iot/init", "fan yang" + (int) (Math.random() * 100000000));
    //        server.setMqttClient("emqx_user", "emqx_password", new MQTTCallback());
    //        server.sub("touchStart"); // 项目启动就开始监听touchStart主题
    //        server.sub("touchEnd");
    //        server.sub("joinRoom");
    //        server.sub("createRoom");
    //        server.sub("deleteRoom");
    //        server.sub("addPage");
    //        server.sub("leaveRoom");
    //        server.sub("deletePage");
    //        server.sub("nextPage");
    //        server.sub("upPage");
    //
    //    } catch (MqttException e) {
    //        log.error(e.getMessage(), e);
    //    }
    //}

    @Override
    public void run(ApplicationArguments args) throws Exception {
        MQTTConnect server = new MQTTConnect();
        server.setMqttClient("emqx_user", "emqx_password", new MQTTCallback());
        try {
            //server.sub("com/iot/init");
            //server.pubS("com/iot/init", "fan yang" + (int) (Math.random() * 100000000));
            //server.sub("touchStart"); // 项目启动就开始监听touchStart主题
            //server.sub("touchEnd");
            //server.sub("joinRoom");
            server.sub("createRoom1");
            //server.sub("deleteRoom");
            //server.sub("addPage");
            //server.sub("leaveRoom");
            //server.sub("deletePage");
            //server.sub("nextPage");
            //server.sub("upPage");

        } catch (MqttException e) {
            log.error(e.getMessage(), e);
        }
    }
}

