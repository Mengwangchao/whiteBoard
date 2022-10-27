package com.xxxx.whiteboard.mqttConn;

import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;


public class MqttSample {
    public static void main(String[] args) {
        String topic       =  "testtopic/1"; // 这个是订阅主题
        String content     =  "Hello World";
        int    qos         =  2;
        String broker      =  "wss://od434124.cn-shenzhen.emqx.cloud:14011";
        String clientId    =  MqttClient.generateClientId();

        //  持久化
        MemoryPersistence persistence = new MemoryPersistence();
        // MQTT 连接选项
        MqttConnectOptions connOpts = new MqttConnectOptions();
        // 设置认证信息
        connOpts.setUserName("emqx_user");
        connOpts.setPassword("emqx_password".toCharArray());

        try {
            MqttClient client = new MqttClient(broker, clientId, persistence);
            // 设置回调
            client.setCallback(new SampleCallback());
            // 建立连接
            System.out.println("Connecting to broker: " + broker);
            client.connect(connOpts);
            System.out.println("Connected to broker: " + broker);
            // 订阅 topic
            client.subscribe(topic, qos);
            System.out.println("Subscribed to topic: " + topic);
            // 发布消息
            MqttMessage message = new MqttMessage(content.getBytes());
            message.setQos(qos);
            client.publish(topic, message);
            System.out.println("Message published");
            client.disconnect();
            System.out.println("Disconnected");
            client.close();
            System.exit(0);
        } catch (MqttException me) {
            System.out.println("reason " + me.getReasonCode());
            System.out.println("msg " + me.getMessage());
            System.out.println("loc " + me.getLocalizedMessage());
            System.out.println("cause " + me.getCause());
            System.out.println("excep " + me);
            me.printStackTrace();
        }
    }
}
