package com.xxxx.whiteboard.util;

import com.sun.xml.internal.ws.api.pipe.ServerTubeAssemblerContext;
import com.xxxx.whiteboard.mapper.RoomMapper;
import com.xxxx.whiteboard.mapper.UserMapper;
import com.xxxx.whiteboard.pojo.Color;
import com.xxxx.whiteboard.pojo.Point;
import com.xxxx.whiteboard.pojo.Room;
import com.xxxx.whiteboard.pojo.User;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * @Author: fan yang
 * @Description: 完成不同主题接口json数据的解析处理
 */
public class JsonTool {

    static String userId;
    static String roomId;
    static int authority; // 当前房间的模式

    @Autowired(required = false)
    static RoomMapper roomMapper;

    @Autowired(required = false)
    static UserMapper userMapper;

    /*
    * 完成接口主题touchStart的相关操作
    * */
    public static void touchStart(JSONObject jsonObject) throws JSONException {
        userId = (String) jsonObject.get("userId");
        roomId = (String) jsonObject.get("roomId");
        Color color = JsonSubTool.getColor((JSONObject) jsonObject.get("color"));
        Point point = JsonSubTool.getPoint((JSONObject) jsonObject.get("point"), color);
    }

    public static void createRoom(JSONObject jsonObject) throws JSONException {
        userId = (String) jsonObject.get("userId");
        roomId = (String) jsonObject.get("roomId");
        authority = (int) jsonObject.get("authority");
        roomMapper.insertRoom(new Room(roomId, 1, authority, 1)); // 在room表插入新房间
        userMapper.insert(new User(userId, roomId)); // 在user里面也添加一下
    }

    /*
     * 加入房间
     * 这里应该要返回所有的
     * @Return: jsonObject
     * */
    public static void joinRoom(JSONObject jsonObject) throws Exception{
        userId = (String) jsonObject.get("userId");
        roomId = (String) jsonObject.get("roomId");
        userMapper.insert(new User(userId, roomId));
    }

    public static void deleteRoom(JSONObject jsonObject) throws Exception{
        userId = (String) jsonObject.get("userId");
        roomId = (String) jsonObject.get("roomId");
        roomMapper.deleteById(roomId);
        userMapper.deleteById(userId);
    }

}
