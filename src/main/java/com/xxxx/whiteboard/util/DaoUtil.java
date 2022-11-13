package com.xxxx.whiteboard.util;

import com.xxxx.whiteboard.mapper.*;
import com.xxxx.whiteboard.pojo.Color;
import com.xxxx.whiteboard.pojo.User;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Random;

/**
 * @Author: fan yang
 * @Description: 把一些常用的数据访问逻辑封装到此类
 */
public class DaoUtil {

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

    /*
    * 查找这个颜色的color_id, 如果数据库里没有就设计一个color_id， 保存进去
    * */
    public static int findOrSaveColor(Color color){
        int colorId = -1;
        int flag = colorMapper.getColorId(color.getR(), color.getG(), color.getB(), color.getA());
        if (flag == 0){ // 说明没有查到这个颜色
            Random random = new Random();
            colorId = random.nextInt(100000);
            color.setColorId(colorId);
            colorMapper.insert(color);
        }else{ // 如果数据库已经保存了这个颜色，获取并返回color_id
            colorId = colorMapper.getColorId(color.getR(), color.getG(), color.getB(), color.getA());
            color.setColorId(colorId);
        }
        return colorId;
    }

    /*
    * user的操作数+1，返回user的操作
    * */
    public static int incrAndGetUserOpId(String userId){
        userMapper.operationNumIncr(userId); // 先自增用户操作次数
        User user = userMapper.selectById(userId);
        return user.getOperationNum(); // 再新获得用户操作id
    }

    /*
     * 删除掉此房间
     * */
    public static void deleteRoom(String roomId) {
        String tableName;
        for (int i = 1; i < 30; i++) {
            tableName = MajorUtil.getTableName(roomId, i);
            // 删除掉所有 page
            pointMapper.dropPage(tableName);
            // 删除掉所有 全局view
            pointMapper.dropPointsViewAll(tableName);
            // 删除掉所有 可视view
            pointMapper.dropPointsViewSightSeeing(tableName);
        }
        // 删除掉次房间的所有操作
        operationMapper.deleteByRoomId(roomId);
        // 在room表中删除掉此房间
        roomMapper.deleteById(roomId);
    }
}
