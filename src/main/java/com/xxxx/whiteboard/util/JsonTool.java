package com.xxxx.whiteboard.util;

import com.xxxx.whiteboard.mapper.PointMapper;
import com.xxxx.whiteboard.mapper.RoomMapper;
import com.xxxx.whiteboard.mapper.UserMapper;
import com.xxxx.whiteboard.mqttConn.MQTTCallback;
import com.xxxx.whiteboard.mqttConn.MQTTConnect;
import com.xxxx.whiteboard.pojo.*;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.ArrayList;
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

    //static String nowPath = System.getProperty("user.dir") + "/tmp_files";

    /*
     * 完成接口主题touchStart的相关操作: 开始划线
     * 创建新房间，存放所有点的（不对这个应该是新建page的时候完成的）
     * 保存点
     * */
    public static void touchStart(JSONObject jsonObject) throws JSONException {
        JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, true);
        if (roomMapper.isTableExist(jg.getRoomId(), jg.getCurrentPage()) == 0) {
            roomMapper.createPage(jg.getRoomId(), jg.getCurrentPage());
        }
        ; // 如果不存在这个页，就创建这个页指定的point表
        pointMapper.savePoint(jg.getRoomId(), jg.getCurrentPage(), jg.getPoint()); // 我觉得保存这里应该开一个线程
        // 我觉得保存这里应该开一个线程
    }

    public static void touching(JSONObject jsonObject) throws JSONException {
        JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, true);
        pointMapper.savePoint(jg.getRoomId(), jg.getCurrentPage(), jg.getPoint());
    }

    // 读取json文件存入数据库
    public static void touchEnd(JSONObject jsonObject) throws JSONException {
        JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, true);
        pointMapper.savePoint(jg.getRoomId(), jg.getCurrentPage(), jg.getPoint());
    }

    /*
     * 加入房间: 表示有人希望加入房间。表示想要请求本房间本页数的所有数据。
     * */
    public static void joinRoom(JSONObject jsonObject) throws JSONException, MqttException {
        JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, true);
        // 找到本房间本页数的所有点集，保存返回json数据
        List<Point> points = pointMapper.getAllPoint(jg.getRoomId(), jg.getCurrentPage());
        JSONObject jsonPointsRet = new JSONObject();
        jsonPointsRet.putOpt("points", points); // 所有点集
        jsonPointsRet.put("roomId", jg.getRoomId());
        jsonPointsRet.put("userId", jg.getUserId());
        jsonPointsRet.put("currentPage", jg.getCurrentPage());
        //jsonPointsRet.put("pageCount", jg.getPageCount());
        Room room = roomMapper.selectById(jg.getRoomId());
        jsonPointsRet.put("pageCount", room.getPageCount());
        // pageCount是从我这取的
        MQTTConnect mqttConnect = new MQTTConnect();
        mqttConnect.setMqttClient("emqx_user", "emqx_password", new MQTTCallback());
        mqttConnect.pub("joinRoomReturn", jsonPointsRet, 2);
        // 这个问题存在就是能不能一次性把所有点都给查出来了

        User user = new User(jg.getUserId(), jg.getRoomId(), jg.getAuthority());
        userMapper.insert(user); // 在user表里面插入用户

    }


    /*
    创建房间：初始page = 1， currentPage = 1，roomState = 1；
    创建了第一页
     * */
    public static void createRoom(JSONObject jsonObject) throws JSONException {
        int roomState = 1, authority = 1, pageCount = 1, currentPage = 1, peopleNum = 1; // 房间authority默认只读
        JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, true);
        Room room = new Room(jg.getRoomId(), roomState, authority, pageCount, currentPage, peopleNum);
        roomMapper.createRoom(room); // 在room表插入房间
        roomMapper.createPage(jg.getRoomId(), currentPage); // 新建一页房间用来装point的
        userMapper.insert(new User(jg.getUserId(), jg.getRoomId(), 2)); // 在user里面也添加一下
        //创建房间的 user 是协作模式
    }

    /*
     * 用户离开房间：room表外链user表，然后这个操作就是用户退出房间，外链表格数据更新
     * */
    public static void leaveRoom(JSONObject jsonObject) throws JSONException {
        JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, false);
        userMapper.deleteById(jg.getUserId());
        if (userMapper.selectCount(jg.getRoomId()) == 0) { // 房间人数为0，删除掉所有页数
            int maxPage = 100;
            for (int i = 1; i <= maxPage; i++) {
                roomMapper.deletePageOfRoom(jg.getRoomId(), i);
            }
        }
        roomMapper.deleteById(jg.getRoomId());
        userMapper.deleteById(jg.getUserId());
    }

    ///*
    //删除房间：还得删掉所有的page建立的表，删掉每个page对应的表
    //* */
    //public static void deleteRoom(JSONObject jsonObject) throws JSONException {
    //    JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, false);
    //    int maxPage = 100; // 初定位一共有100页，之后要改成查询出来总页数
    //    // 删除掉每一页的关联表
    //    for (int i = 1; i <= maxPage; i++) {
    //        roomMapper.deletePageOfRoom(jg.getRoomId(), i);
    //    }
    //    roomMapper.deleteById(jg.getRoomId());
    //    userMapper.deleteById(jg.getUserId());
    //}

    /*
     * 在末尾添加一个新的白板页，总页数加一。
     * */
    public static void addPage(JSONObject jsonObject) throws JSONException {
        JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, false);
        Room room = roomMapper.selectById(jg.getRoomId());
        int pageCount = room.getPageCount() + 1;
        room.setPageCount(pageCount);
        roomMapper.updateById(room);
        roomMapper.createPage(room.getRoomId(), pageCount);
    }

    /*
    删除页数: 从被删除页数的后一页开始，数据库中表名进行一个迭代修改
    * */
    public static void deletePage(JSONObject jsonObject) throws JSONException {
        JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, true);
        Room room = roomMapper.selectById(jg.getRoomId()); // 查询到整个房间
        int oldPageCount = room.getPageCount();
        roomMapper.deletePageOfRoom(jg.getRoomId(), jg.getCurrentPage()); // 删除数据库中页
        // 把此页之后的页数逐个减一
        for (int i = jg.getCurrentPage() + 1; i >= 0; i--) {
            // 判断这个表是否存在
            if (roomMapper.isTableExist(jg.getRoomId(), i) == 1) {
                roomMapper.renameTablePage(jg.getRoomId(), i, i - 1);
            }
        }
        room.setPageCount(room.getPageCount() - 1);
        roomMapper.updateById(room); // 房间页数减一

        // 然后剩余的页数全都减一
    }

    /*
    下一页白板：如果这个没被加载过的话，前端会向我发送一个相关请求
    * */
    public static void nextPage(JSONObject jsonObject) throws JSONException {
        JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, false);
        Room room = roomMapper.selectById(jg.getRoomId());
        room.setCurrentPage(room.getCurrentPage() - 1);
        roomMapper.updateById(room);
    }

    public static void upPage(JSONObject jsonObject) throws JSONException {
        JsonGetter jg = JsonSubTool.initJsonObject(jsonObject, false);
        Room room = roomMapper.selectById(jg.getRoomId());
        room.setCurrentPage(room.getCurrentPage() + 1);
        roomMapper.updateById(room);
    }


}
