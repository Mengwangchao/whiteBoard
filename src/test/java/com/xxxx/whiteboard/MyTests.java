package com.xxxx.whiteboard;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xxxx.whiteboard.mapper.RoomMapper;
import com.xxxx.whiteboard.pojo.Color;
import com.xxxx.whiteboard.pojo.Room;
import com.xxxx.whiteboard.pojo.User;
import com.xxxx.whiteboard.mapper.UserMapper;
import com.xxxx.whiteboard.mqttConn.MQTTCallback;
import com.xxxx.whiteboard.mqttConn.MQTTConnect;
import com.xxxx.whiteboard.util.RunSqlScript;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.json.JSONException;
import org.json.JSONObject;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class MyTests {


    @Autowired(required = false)
    private UserMapper userMapper;

    @Autowired(required = false)
    private RoomMapper roomMapper;

    /*
    测试连接数据库
    */
    @Test
    void addUserTest() {
        User user1 = new User("1314", "12121");
        userMapper.insert(user1);
    }

    /*
    测试mqtt连接
    */
    @Test
    void mqttConnTest() throws MqttException {
        MQTTConnect mqttConnect = new MQTTConnect();
        mqttConnect.setMqttClient("emqx_user", "emqx_password", new MQTTCallback());
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

    /*
    测试动态建表
    * */
    @Test
    void dynamicTableTest() {
        String roomId = "134123454";
        String tableName = "room" + roomId;
        roomMapper.createRoom(new Room("134123454", 1, 1));
        roomMapper.insert(new Room("134123454", 1, 1));
    }

    /*
    测试运行SQL脚本
    * */
    //@Test
    //void runSqlTest(){
    //    RunSqlScript.run("createRoom");
    //}

        /*
    测试插入房间
    * */
    @Test
    void insertRoomTest(){
        roomMapper.insertRoom(new Room("1234", 1, 1));
    }


}
