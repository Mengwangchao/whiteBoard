package com.xxxx.whiteboard.util;

import com.xxxx.whiteboard.mapper.PointMapper;
import com.xxxx.whiteboard.mapper.RoomMapper;
import com.xxxx.whiteboard.mapper.UserMapper;
import com.xxxx.whiteboard.pojo.*;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;

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
     * 加入房间
     * 这里应该要返回所有的
     * @Return: jsonObject
     * */
    public static void joinRoom(JSONObject jsonObject) throws JSONException {
        JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, false);

    }


    /*
    创建房间：初始page = 1， currentPage = 1，roomState = 1；
    创建了第一页
     * */
    public static void createRoom(JSONObject jsonObject) throws JSONException {
        int roomState = 1, page = 1, currentPage = 1;
        JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, true);
        Room room = new Room(jg.getRoomId(), roomState, jg.getAuthority(), page, currentPage);
        roomMapper.createRoom(room); // 在room表插入房间
        roomMapper.createPage(jg.getRoomId(), currentPage); // 新建一页房间用来装点的
        userMapper.insert(new User(jg.getUserId(), jg.getRoomId())); // 在user里面也添加一下

    }

    public static void joinRoomReturn() {

    }

    /*
    还得删掉所有的page建立的表
    * */
    public static void deleteRoom() {
        //roomMapper.deleteById(roomId);
        //userMapper.deleteById(userId);
    }

    public static void addPage() {

    }

    public static void deletePage() {

    }


    public static void nextPage() {

    }

    public static void upPage() {

    }
    

}
