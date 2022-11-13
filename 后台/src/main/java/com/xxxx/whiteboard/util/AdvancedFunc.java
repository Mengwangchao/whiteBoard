package com.xxxx.whiteboard.util;

import com.xxxx.whiteboard.mapper.*;
import com.xxxx.whiteboard.pojo.Image;
import com.xxxx.whiteboard.pojo.Operation;
import com.xxxx.whiteboard.util.DaoUtil;
import com.xxxx.whiteboard.util.JsonSubTool;
import com.xxxx.whiteboard.util.MajorUtil;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * @Author: fan yang
 * @Description:
 */
public class AdvancedFunc {
    @Autowired(required = false)
    static RoomMapper roomMapper;

    @Autowired(required = false)
    static UserMapper userMapper;

    @Autowired(required = false)
    static ColorMapper colorMapper;

    @Autowired(required = false)
    static OperationMapper operationMapper;

    @Autowired(required = false)
    static PointMapper pointMapper;

    @Autowired(required = false)
    static ImageMapper imageMapper;

    /*
     * 1. 首先在operation里记录本次操作
     * 2. 在map中取到此次操作的operationId
     * 3. 将image存到数据库
     *  (num设置成主键并递增)
     * */
    public static void addImageStart(JSONObject jObj) throws JSONException {
        // 只要addImage就需要把num改了, num是image表的count(*)
        Image img = JsonSubTool.initJsonOjAdv(jObj, false);

        int newUserOpId = DaoUtil.incrAndGetUserOpId(img.getUserId());// operation表里面，记录用户的此次操作（比如第一次、第二次）
        img.setOperationId(newUserOpId); // 将这个图形赋予id
        imageMapper.insert(img);
        // 将此次操作记录在册
        Operation op = new Operation(img.getUserId(), img.getRoomId(), img.getCurrentPage(), MajorUtil.getTableName(img.getRoomId(), img.getCurrentPage()),
                0, 0, 0, 0, newUserOpId);
        operationMapper.insert(op);
        MajorUtil.map.put(img.getUserId(), newUserOpId);
    }

    /*
     * 图片刚开始放置时候涉及的移动
     * 通过num来update这个image的数据
     * */
    public static void addImageScrolling(JSONObject jObj) throws JSONException {
        Image img = JsonSubTool.initJsonOjAdv(jObj, false);
        // 取到这次用户的操作id
        // 把image存到表里
        imageMapper.updateById(img);
    }

    /*
     * 图片滑动结束
     * 通过num来update这个image的数据
     * */
    public static void addImageEnd(JSONObject jObj) throws JSONException {
        Image img = JsonSubTool.initJsonOjAdv(jObj, false);
        imageMapper.updateById(img);//这个id是num
        // 删除此次操作的key
        // MajorUtil.map.remove(img.getUserId()); // 移除掉此次的操作记录
        // 这个map记录了用户此次的操作id
    }

    /*
     * 锁住此时的图片：将数据库中共这个图片设置成locked
     * */
    public static void lockImage(JSONObject jObj) throws JSONException {
        Image img = JsonSubTool.initJsonOjAdv(jObj, false);
        // 取到这次用户的操作id
        img.setLocked(true);
        imageMapper.updateById(img);
    }

    /*
     * 图片的平移
     * */
    public static void translation(JSONObject jObj) throws JSONException {
        Image img = JsonSubTool.initJsonOjAdv(jObj, false);
        if (!img.isLocked()) {
            imageMapper.updateById(img);
            //imageMapper.updateByOperationId();
        }
        // 如果被锁了就不能动了
    }

    /*
     * 旋转一个图片，绕中心点旋转
     * 上锁了就不能旋转
     * */
    public static void rotateImage(JSONObject jObj) throws JSONException {
        Image img = JsonSubTool.initJsonOjAdv(jObj, false);
        imageMapper.updateById(img);
    }



}
