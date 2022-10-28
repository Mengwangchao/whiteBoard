package com.xxxx.whiteboard;

import com.xxxx.whiteboard.entity.User;
import com.xxxx.whiteboard.mapper.UserMapper;
import com.xxxx.whiteboard.mqttConn.Callback;
import com.xxxx.whiteboard.mqttConn.MQTTConnect;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationEventPublisher;

import java.util.Arrays;
import java.util.List;

@SpringBootTest
class MyTests {


    @Autowired(required = false)
    private UserMapper userMapper;

    // 测试连接数据库
    @Test
    void addUserTest() {
        //List<User> users = userService.findAllUsers();
        //System.out.println(Arrays.toString(new List[]{users}));
        User user1 = new User("1314", "12121");
        userMapper.insert(user1);
    }

    // 测试mqtt连接
    @Test
    void mqttConnTest() throws MqttException {
        MQTTConnect mqttConnect = new MQTTConnect();
        mqttConnect.setMqttClient("emqx_user", "emqx_password", new Callback());
        mqttConnect.sub("com/iot/init");
        mqttConnect.sub("touchStart");
        mqttConnect.pub("com/iot/init", "Mr.Qu" + (int) (Math.random() * 100000000));
    }


}
