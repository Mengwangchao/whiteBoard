package com.xxxx.whiteboard;

import com.baomidou.mybatisplus.annotation.TableName;
import com.xxxx.whiteboard.mapper.PointMapper;
import com.xxxx.whiteboard.mapper.RoomMapper;
import com.xxxx.whiteboard.pojo.Color;
import com.xxxx.whiteboard.pojo.Point;
import com.xxxx.whiteboard.pojo.Room;
import com.xxxx.whiteboard.pojo.User;
import com.xxxx.whiteboard.mapper.UserMapper;
import com.xxxx.whiteboard.mqttConn.MQTTCallback;
import com.xxxx.whiteboard.mqttConn.MQTTConnect;
import com.xxxx.whiteboard.util.RunSqlScript;
import com.xxxx.whiteboard.validator.ValidatorUtil;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.json.JSONException;
import org.json.JSONObject;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.w3c.dom.stylesheets.LinkStyle;

import javax.validation.Valid;
import java.util.List;

@SpringBootTest
class MyTests {


    @Autowired(required = false)
    private UserMapper userMapper;

    @Autowired(required = false)
    private RoomMapper roomMapper;

    @Autowired(required = false)
    private PointMapper pointMapper;

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
        roomMapper.createPage("134123454", 1);
        roomMapper.insert(new Room("134123454", 1, 1, 1, 1, 1));
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
    void insertRoomTest() {
        roomMapper.createRoom(new Room("1234", 1, 1, 1, 1,1));
    }

    /*
    测试建立某房间某页数的表，用来存储此页的所有point
    * */
    @Test
    void createRoomTest() {
        roomMapper.createPage("1234", 1);
    }

    /*
    测试保存一个点到数据库
    * */
    @Test
    void savePointTest() {
        Point point = new Point(1.0f, 2.0f, new Color(1.0f, 1.0f, 1.0f, 1.0f));
        pointMapper.savePoint("1234", 1, point);
    }

    /*
    * 测试获取某房间某页的所有点
    * */
    @Test
    void getAllPointTest(){
        List<Point> points = pointMapper.getAllPoint("1234", 1);
        System.out.println(points.toString());
    }

    /*
     * 测试改变房间的room_state
     * */
    @Test
    void setRoomState(){
        roomMapper.setRoomState("1234", 10);
    }

    @Test
    void deletePageOfRoomTest(){
        roomMapper.deletePageOfRoom("12345", 1);
    }

    @Test
    void isRoomIdTest(){
        System.out.println(ValidatorUtil.isRoomId("123456789012"));
        Room room = new Room("1234", 1,1,1,1,1);
        System.out.println(roomMapper.selectById("1234"));
        System.out.println(room);
    }
}
