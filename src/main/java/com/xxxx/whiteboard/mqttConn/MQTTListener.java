package com.xxxx.whiteboard.mqttConn;

import lombok.extern.slf4j.Slf4j;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationListener;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.stereotype.Component;

/**
 * 项目启动 监听主题
 * ContextRefreshedEvent 是指项目启动完毕
 *
 * @author fan yang
 * @since 2022/10/28
 */
@Slf4j
@Component
public class MQTTListener implements ApplicationListener<ContextRefreshedEvent> {

    private final MQTTConnect server;

    @Autowired
    public MQTTListener(MQTTConnect server) {
        this.server = server;
    }

    @Override
    public void onApplicationEvent(ContextRefreshedEvent contextRefreshedEvent) {
        try {
            server.setMqttClient("emqx_user", "emqx_password", new MQTTCallback());
            server.sub("touchStart"); // 项目启动就开始监听touchStart主题
            server.sub("正则表达式12位数字"); // 项目启动就开始监听touching主题
            server.sub("touchEnd");
            server.sub("joinRoom");
            server.sub("createRoom");
            server.sub("deleteRoom");
            server.sub("addPage");
            server.sub("deletePage");
            server.sub("nextPage");
            server.sub("upPage");

        } catch (MqttException e) {
            log.error(e.getMessage(), e);
        }
    }
}

