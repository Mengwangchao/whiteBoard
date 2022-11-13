package com.xxxx.whiteboard.handler;

import com.xxxx.whiteboard.mapper.*;
import com.xxxx.whiteboard.mqttConn.MQTTCallback;
import com.xxxx.whiteboard.mqttConn.MQTTConnect;
import com.xxxx.whiteboard.pojo.*;
import com.xxxx.whiteboard.util.DaoUtil;
import com.xxxx.whiteboard.util.JsonPojo;
import com.xxxx.whiteboard.util.JsonSubTool;
import com.xxxx.whiteboard.util.MajorUtil;
import lombok.extern.slf4j.Slf4j;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
import java.util.List;

/**
 * @Author: fan yang
 * @Description:
 */
@Slf4j
@Component
public class BasicHandler {

    private static BasicHandler that;

    @Resource
    RoomMapper roomMapper;

    @Resource
    UserMapper userMapper;

    @Resource
    ColorMapper colorMapper;

    @Resource
    OperationMapper operationMapper;

    @Resource
    PointMapper pointMapper;


    //@PostConstruct
    //public void init(){
    //    that = this;
    //    that.roomMapper = this.roomMapper;
    //    that.userMapper = this.userMapper;
    //    that.colorMapper = this.colorMapper;
    //    that.operationMapper = this.operationMapper;
    //    that.pointMapper = this.pointMapper;
    //}


    /*
     *  开始触碰: user的operation_num属性自增
     *  1. color的存储或者color_id的获取
     *  2. 获取到user的operationNum，得到此次的operationId（operationNum + 1）
     *  2. 在points表中，先插入这个点
     *  3. operation中记录此次的操作
     *  4. 在map中保留此次的id
     * */
    public void touchStart(JSONObject jsonObject) throws JSONException {
        JsonPojo jg = JsonSubTool.initJsonOj(jsonObject, true); // 先获取到所有的
        // user表的操作次数自增，并获取到这一次的id（是用户第几次操作）
        int newUserOpId = DaoUtil.incrAndGetUserOpId(jg.getUserId());// operation表里面，记录用户的此次操作（比如第一次、第二次）
        // Color表查询是否有此颜色，如果没有，插入到color表中
        Color color = jg.getColor();
        color.setColorId(DaoUtil.findOrSaveColor(color));// 这是一个完整的颜色
        // point方面：把这个点记到表格里面
        Point point = new Point(jg.getPoint().getX(), jg.getPoint().getY(), color.getColorId(), newUserOpId);
        pointMapper.insertPoint(point, MajorUtil.getTableName(jg.getRoomId(), jg.getCurrentPage()));
        // 将此次操作记录在册
        Operation op = new Operation(jg.getUserId(), jg.getRoomId(), jg.getCurrentPage(), MajorUtil.getTableName(jg.getRoomId(), jg.getCurrentPage()),
                jg.getGraphical(), jg.getLineWidth(), 0, color.getColorId(), newUserOpId);
        operationMapper.insert(op);

        MajorUtil.map.put(jg.getUserId(), newUserOpId);
    }

    /*
     * 传输过程：
     * 1. 获取到此次操作id， 的相关参数
     * 2. 把点存在表格里
     * */
    public void touching(JSONObject jsonObject) throws JSONException {
        JsonPojo jg = JsonSubTool.initJsonOj(jsonObject, true);
        // 取到这次用户的操作id
        int operationId = MajorUtil.map.get(jg.getUserId());
        Operation op = operationMapper.selectById(operationId); // 获取到此次操作

        // 把点存在表格里
        Point point = new Point(jg.getPoint().getX(), jg.getPoint().getY(), op.getColorId(), operationId);
        pointMapper.insertPoint(point, MajorUtil.getTableName(jg.getRoomId(), jg.getCurrentPage()));

    }

    /*
     * 传输结束：
     * 1. 获取到此次操作id， 的相关参数
     * 2. 把点存在表格里
     * 3. 删除此次操作保留的key
     * */
    public void touchEnd(JSONObject jsonObject) throws JSONException {
        // 最后新建operationId
        JsonPojo jg = JsonSubTool.initJsonOj(jsonObject, true);
        // 取到这次用户的操作id
        int operationId = MajorUtil.map.get(jg.getUserId());
        // 把点存在表格里
        Operation op = operationMapper.selectById(operationId);

        Point point = new Point(jg.getPoint().getX(), jg.getPoint().getY(), op.getColorId(), operationId);
        pointMapper.insertPoint(point, MajorUtil.getTableName(jg.getRoomId(), jg.getPageCount()));
        // 删除此次操作的key
        MajorUtil.map.remove(jg.getUserId()); // 移除掉此次的操作记录
    }

    /*
     * 新用户进入房间：
     * 1. 现在user里面添加这个用户
     * 2. room里面总人数+1
     * 3. 已知当前房间和当前页，把本页所有可视点返回出来
     * 4. 发布到mqtt中
     * */
    public void joinRoom(JSONObject jsonObject) throws JSONException, MqttException {
        JsonPojo jg = JsonSubTool.initJsonOj(jsonObject, true);

        // 先把用户添加进去
        User user = new User(jg.getUserId(), jg.getRoomId(), jg.getAuthority(), 0);
        userMapper.insert(user);

        // 房间人数加一
        roomMapper.personNumIncr(jg.getRoomId());

        // 已知当前房间和当前页：获取本页的所有可视点集，发出去
        List<Point> points = pointMapper.selectPointsViewSightSeeing(MajorUtil.getTableName(jg.getRoomId(), jg.getCurrentPage()));
        //= operationMapper.selectPoints(tableName);
        JSONObject jsonPointsRet = new JSONObject();
        jsonPointsRet.putOpt("points", points.toString()); // 所有点集
        jsonPointsRet.put("roomId", jg.getRoomId());
        jsonPointsRet.put("userId", jg.getUserId());
        jsonPointsRet.putOpt("currentPage", jg.getCurrentPage() + "");
        // pageCount是从我这取的
        Room room = roomMapper.selectById(jg.getRoomId());
        jsonPointsRet.put("pageCount", room.getPageCount() + "");

        MQTTConnect mqttConnect = new MQTTConnect();
        mqttConnect.setMqttClient("emqx_user", "emqx_password", new MQTTCallback());
        mqttConnect.pub("joinRoomReturn", jsonPointsRet, 2);
    }


    /*
     * 新建房间：
     * 1. 在user表中把user注册进去
     * 2. 在room表中把这个新房间注册进去
     * 3. 新建一个page
     * 4. 新建此page的视图
     * 5. 把新建房间的操作放到操作里，相当于此用户第0次操作
     * 6. 订阅以roomId为topic的主题
     * */
    public void createRoom(JSONObject jsonObject) throws JSONException, MqttException {
        int pageCount = 1, currentPage = 1, peopleNum = 1;

        //JsonPojo jg = JsonSubTool.initJsonOj(jsonObject, true);
        JsonPojo jg = new JsonPojo();
        jg.setRoomId(jsonObject.getString("roomId"));
        jg.setAuthority(Integer.parseInt(jsonObject.getString("authority")));
        jg.setUserId(jsonObject.getString("userId"));
        System.out.println(jg);
        // 在room表中对房间记录在册
        Room room = new Room(jg.getRoomId(), pageCount, currentPage, peopleNum);
        System.out.println(room);
        roomMapper.insertRoom(room);

        // 在user表中记录在册
        int authority = 1, operationNum = 0;
        User user = new User(jg.getUserId(), jg.getRoomId(), authority, operationNum);
        userMapper.insert(user);

        // 新建一个第一页 & 此页的视图
        pointMapper.createPage(MajorUtil.getTableName(jg.getRoomId(), currentPage));
        //pointMapper.createPointsViewAll(MajorUtil.getTableName(jg.getRoomId(), currentPage));
        pointMapper.createPointViewSightSeeing(MajorUtil.getTableName(jg.getRoomId(), currentPage));

        // 把这个建表操作放到记录里：因为数据库中初始化这个用户的初始信息，例如operationId从 0 开始
        Operation op = new Operation(jg.getUserId(), jg.getRoomId(), 1,
                MajorUtil.getTableName(jg.getRoomId(), currentPage), 0,
                0, 0, 0, 0);
        operationMapper.insert(op);
        // 这个页数应该是一个视图_把所有用户画出来的东西拼在了一起，现在就是要新建一个这样的视图

        // 订阅以roomId的主题
        MQTTConnect mqttConnect = new MQTTConnect();
        mqttConnect.setMqttClient("emqx_user", "emqx_password", new MQTTCallback());
        mqttConnect.sub(jg.getRoomId());
    }

    /*
     * 离开房间：
     * 离开房间后，用户之前画的东西和点还是在的
     * 0. 所以operation保留、points保留
     * 1. room人数更新
     * 2. user从user表中删除
     * 3. user走了之后，如果房间人数变为0，删除掉此房间
     * */
    public void leaveRoom(JSONObject jsonObject) throws JSONException {
        JsonPojo jg = JsonSubTool.initJsonOj(jsonObject, false);
        // 房间人数自动递减
        roomMapper.personNumDecr(jg.getRoomId());
        if (roomMapper.selectById(jg.getRoomId()).getPeopleNum() == 0) {
            DaoUtil.deleteRoom(jg.getRoomId());
        } // 如果房间人数变成0，删除掉此房间
        // user从user表里删除
        userMapper.deleteById(jg.getUserId());
    }

    /*
     * 添加页数：
     * 1. room表中pageCount++
     * 2. 新建这一页的点集表存放点集
     * 3. 创建此页的查询视图
     * */
    public void addPage(JSONObject jsonObject) throws JSONException {
        JsonPojo jg = JsonSubTool.initJsonOj(jsonObject, false);
        // room里面ageCount + 1
        roomMapper.roomPageIncr(jg.getRoomId());

        // 获取到总页数
        int pageCount = roomMapper.selectById(jg.getRoomId()).getPageCount();

        // 新建一页存放点集
        pointMapper.createPage(MajorUtil.getTableName(jg.getRoomId(), pageCount + 1));

        // 创建此页数的查询视图
        //pointMapper.createPointsViewAll(MajorUtil.getTableName(jg.getRoomId(), pageCount + 1));
        pointMapper.createPointViewSightSeeing(MajorUtil.getTableName(jg.getRoomId(), pageCount + 1));
    }

    /*
    删除某一页： 把currentPage以及之后的所有页数都 - 1
    1. 不对: 先删除掉对应的点集r1234_p1
    2. 再把operation中的所有currentPage = currentPage的operation删掉
    3. 再把operation所有大于currentPage的currentPage - 1
    4. 再把room中的总页数递减
    * */
    public void deletePage(JSONObject jsonObject) throws JSONException {
        JsonPojo jg = JsonSubTool.initJsonOj(jsonObject, false);
        // 删除此页点集points
        pointMapper.dropPage(MajorUtil.getTableName(jg.getRoomId(), jg.getCurrentPage()));
        pointMapper.dropPointsViewAll(MajorUtil.getTableName(jg.getRoomId(), jg.getCurrentPage()));
        pointMapper.dropPointsViewSightSeeing(MajorUtil.getTableName(jg.getRoomId(), jg.getCurrentPage()));
        // 删除掉当前页的所有operation
        operationMapper.deleteByCurrentPage(jg.getRoomId(), jg.getCurrentPage());
        // 把operation中所有大于currentPage的currentpage-1
        operationMapper.biggerCurrentPageDecr(jg.getRoomId(), jg.getCurrentPage());
        // 把room中的总页数递减
        roomMapper.roomPageDecr(jg.getRoomId());
    }

    /*
     * 翻页到下一页：
     * 其实就是currentPage改变：
     * 获取到pageCount和currentPage，如果相等，就变成1，否则 + 1
     * */
    public void nextPage(JSONObject jsonObject) throws JSONException {
        // 向下翻页
        JsonPojo jg = JsonSubTool.initJsonOj(jsonObject, false);
        Room room = roomMapper.selectById(jg.getRoomId());
        int currentPage = room.getCurrentPage();
        int pageCount = room.getPageCount();
        // 下一页白板
        if (currentPage == pageCount || pageCount == 1) {
            currentPage = 1; // 如果只有一页，不变；如果是最后一页，变成1
        } else {
            currentPage += 1;
        }
        room.setCurrentPage(currentPage);
        roomMapper.updateById(room);
    }

    public void upPage(JSONObject jsonObject) throws JSONException {
        // 向上翻页
        JsonPojo jg = JsonSubTool.initJsonOj(jsonObject, false);
        Room room = roomMapper.selectById(jg.getRoomId());

        int currentPage = room.getCurrentPage(); // 获取到当前页
        int pageCount = room.getPageCount(); // 获取页数
        // 下一页白板
        if (pageCount == 1) {
            currentPage = 1;
        } else if (currentPage == 1) {
            currentPage = pageCount;
        }// 如果已经是最大页了
        else {
            currentPage -= 1;
        }
        room.setCurrentPage(currentPage);
        roomMapper.updateById(room);
    }


}
