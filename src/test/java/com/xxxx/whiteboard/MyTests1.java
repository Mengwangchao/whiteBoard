package com.xxxx.whiteboard;

import com.xxxx.whiteboard.mapper.OperationMapper;
import com.xxxx.whiteboard.mapper.PointMapper;
import com.xxxx.whiteboard.mapper.RoomMapper;
import com.xxxx.whiteboard.pojo.Point;
import com.xxxx.whiteboard.util.MajorUtil;
import lombok.ToString;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.List;

/**
 * @Author: fan yang
 * @Description:
 */
@SpringBootTest
public class MyTests1 {

    @Autowired(required = false)
    private PointMapper pointMapper;

    @Autowired(required = false)
    private RoomMapper roomMapper;

    @Autowired(required = false)
    private OperationMapper operationMapper;

    /*
    新建视图
    */
    @Test
    void createViewTest(){
        pointMapper.createPointsViewAll("r1234p_1");
    }

    /*
    插入点到点集表格
    */
    @Test
    void insertPoints(){
        Point point = new Point(123, 12, 13, 44);
        pointMapper.insertPoint(point, "r1234p_1");
    }

    /*
    新建页数
    */
    @Test
    void createPage(){
        pointMapper.dropPage("12345");
        pointMapper.createPage("12345");
    }

    /*
    * 查询一整页的视图
    * */
    @Test
    void selectPointsViewTest(){
        List<Point> points = pointMapper.selectPointsViewAll("r1234p_1");
        System.out.println(points);
    }

    /*
    * 测试map是否好用，能否正常存取
    * */
    @Test
    void mapTest(){
        MajorUtil.map.put("1234", 12);
        System.out.println(MajorUtil.map.get("1234"));
    }


    /*
    * 删除某用户在表中的所有操作
    * */
    @Test
    void deleteOperationOfUserIdTest(){
        operationMapper.deleteById("1234");
    }




}
