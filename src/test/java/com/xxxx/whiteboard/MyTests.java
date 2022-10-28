package com.xxxx.whiteboard;

import com.xxxx.whiteboard.entity.Color;
import com.xxxx.whiteboard.entity.Room;
import com.xxxx.whiteboard.entity.User;
import com.xxxx.whiteboard.mapper.UserMapper;
import com.xxxx.whiteboard.mqttConn.Callback;
import com.xxxx.whiteboard.mqttConn.MQTTConnect;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.json.JSONException;
import org.json.JSONObject;
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

    /*
    测试连接数据库
    */
    @Test
    void addUserTest() {
        //List<User> users = userService.findAllUsers();
        //System.out.println(Arrays.toString(new List[]{users}));
        User user1 = new User("1314", "12121");
        userMapper.insert(user1);
    }

     /*
     测试mqtt连接
     */
    @Test
    void mqttConnTest() throws MqttException {
        MQTTConnect mqttConnect = new MQTTConnect();
        mqttConnect.setMqttClient("emqx_user", "emqx_password", new Callback());
        mqttConnect.sub("com/iot/init");
        mqttConnect.sub("touchStart");
        mqttConnect.pub("com/iot/init", "Mr.Qu" + (int) (Math.random() * 100000000));
    }

    /*
    测试json数据的获取 和 封装
    * */
    @Test
    void JsonTest() throws JSONException {
        /* 封装 */
        JSONObject j1 = new JSONObject();
        j1.put("userId", "user16662142421");
        j1.put("roomId", "1234567890");
        System.out.println(j1.get("userId"));

        /* 封装对象 */
        Color color = new Color(12, 12, 12, 12);
        j1.put("color", color);

        /*转换成对象*/
        Color getTheColor = (Color) j1.get("color");
        System.out.println(getTheColor);

    }



}
