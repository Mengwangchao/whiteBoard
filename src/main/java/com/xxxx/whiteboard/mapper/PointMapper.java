package com.xxxx.whiteboard.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.xxxx.whiteboard.pojo.Point;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * @Author: fan yang
 * @Description:
 */
@Repository
public interface PointMapper extends BaseMapper<Point> {


    // 把某表的点插入进去
    void insertPoint(@Param("point") Point point, @Param("tableName") String tableName);

    // 新建页数
    void createPage(@Param("tableName") String tableName);

    // 新建视图
    void createPointsViewAll(@Param("tableName") String tableName);

    // 获取所有可视点，作为一个视图
    void createPointViewSightSeeing(@Param("tableName") String tableName);

    // 查询所有点集
    List<Point> selectPointsViewAll(@Param("tableName") String tableName);

    // 查询所有点集
    List<Point> selectPointsViewSightSeeing(@Param("tableName") String tableName);

    // 如果有这个表的话，就删除
    // 可以作为建表前的预判，还有删除房间时候尽心的删除
    // 其实就是通过表名删除某表
    void dropPage(@Param("tableName") String tableName);

    // 删除视图
    void dropPointsViewAll(@Param("tableName") String tableName);

    // 删除可视视图
    void dropPointsViewSightSeeing(@Param("tableName") String tableName);


    // 删除这个房间，也就是删除所有roomId开头的表和视图
    //void deleteRoom(@Param("roomId") String roomId);

}
