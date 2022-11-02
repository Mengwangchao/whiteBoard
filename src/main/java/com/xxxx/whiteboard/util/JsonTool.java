package com.xxxx.whiteboard.util;

import com.xxxx.whiteboard.mapper.PointMapper;
import com.xxxx.whiteboard.mapper.RoomMapper;
import com.xxxx.whiteboard.mapper.UserMapper;
import com.xxxx.whiteboard.mqttConn.MQTTCallback;
import com.xxxx.whiteboard.mqttConn.MQTTConnect;
import com.xxxx.whiteboard.pojo.*;
import org.apache.ibatis.annotations.Param;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

/**
 * @Author: fan yang
 * @Description: 完成不同主题接口json数据的解析处理
 */
public class JsonTool {

    @Autowired(required = false)
    static RoomMapper roomMapper;

    @Autowired(required = false)
    static UserMapper userMapper;

    @Autowired(required = false)
    static PointMapper pointMapper;


    /*
     * 完成接口主题touchStart的相关操作: 开始划线
     * 创建新房间，存放所有点的（不对这个应该是新建page的时候完成的）
     * 保存点
     * */
    public static void touchStart(JSONObject jsonObject) throws JSONException {
        JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, true);
        //roomMapper.createRoom(jg.getRoomId(), jg.getCurrentPage());
        pointMapper.savePoint(jg.getRoomId(), jg.getCurrentPage(), jg.getPoint()); // 我觉得保存这里应该开一个线程
    }

    public static void touching(JSONObject jsonObject) throws JSONException {
        JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, true);
        pointMapper.savePoint(jg.getRoomId(), jg.getCurrentPage(), jg.getPoint());
    }

    public static void touchEnd(JSONObject jsonObject) throws JSONException {
        JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, true);
        pointMapper.savePoint(jg.getRoomId(), jg.getCurrentPage(), jg.getPoint()); // touchEnd线程关掉
    }

    /*
     * 加入房间: 房间里的roomStatus加一
     * @Return: jsonObject
     * */
    public static void joinRoom(JSONObject jsonObject) throws JSONException, MqttException {
        JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, false);
        // 房间里的roomState加一
        Room room = roomMapper.selectById(jg.getRoomId());
        room.setRoomState(room.getRoomState() + 1);
        roomMapper.updateById(room);
    }


    /*
    创建房间：初始page = 1， currentPage = 1，roomState = 1；
    创建了第一页
     * */
    public static void createRoom(JSONObject jsonObject) throws JSONException {
        int roomState = 1, page = 1, currentPage = 1, maxPage = 1;
        JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, true);
        Room room = new Room(jg.getRoomId(), roomState, jg.getAuthority(), page, currentPage, maxPage);
        roomMapper.createRoom(room); // 在room表插入房间
        roomMapper.createPage(jg.getRoomId(), currentPage); // 新建一页房间用来装point的
        userMapper.insert(new User(jg.getUserId(), jg.getRoomId())); // 在user里面也添加一下

    }

    public static void joinRoomReturn(JSONObject jsonObject) throws JSONException, MqttException {
        JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, true);
        Room room = roomMapper.selectById(jg.getRoomId());
        if (room.getRoomState() <= 0) return;
        List<Point> points = pointMapper.getAllPoint(jg.getRoomId(), jg.getCurrentPage());
        JSONObject jsonObjectRet = new JSONObject();
        jsonObjectRet.putOpt("points", points);
        MQTTConnect mqttConnect = new MQTTConnect();
        mqttConnect.setMqttClient("emqx_user", "emqx_password", new MQTTCallback());
        mqttConnect.pub("joinRoomReturn", jsonObjectRet, 2);
        // 判断该roomId是否活跃，若活跃则返回新用户加入前其他人的所有操作，用来使后加入的人和之前的人数据同步。
        // 若不活跃，则authority默认为2，所有操作为null
    }

    /*
    删除房间：还得删掉所有的page建立的表，删掉每个page对应的表
    * */
    public static void deleteRoom(JSONObject jsonObject) throws JSONException {
        JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, false);
        int maxPage = roomMapper.selectById(jg.getRoomId()).getMaxPage();
        // 删除掉每一页的关联表
        for (int i = 1; i <= maxPage; i++) {
            roomMapper.deletePageOfRoom(jg.getRoomId(), i);
        }
        roomMapper.deleteById(jg.getRoomId());
        userMapper.deleteById(jg.getUserId());
    }

    /*
     * 在末尾添加一个新的白板页，总页数加一。
     * */
    public static void addPage(JSONObject jsonObject) throws JSONException {
        JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, false);
        Room room = roomMapper.selectById(jg.getRoomId());
        int page = room.getPage() + 1;
        room.setPage(page);
        roomMapper.updateById(room);
        roomMapper.createPage(room.getRoomId(), page);
    }

    public static void deletePage(JSONObject jsonObject) throws JSONException {
        JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, false);
        Room room = roomMapper.selectById(jg.getRoomId());
        room.setPage(room.getPage() - 1);
        roomMapper.updateById(room); // 房间页数减一
        roomMapper.deletePageOfRoom(jg.getRoomId(), jg.getCurrentPage()); // 删除数据库中页
    }

    /*
    下一页白板：如果这个没被加载过的话，前端会向我发送一个相关请求
    * */
    public static void nextPage() {

    }

    public static void upPage() {

    }


}
