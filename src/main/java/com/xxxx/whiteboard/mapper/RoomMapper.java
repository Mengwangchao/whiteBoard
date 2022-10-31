package com.xxxx.whiteboard.mapper;

import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.xxxx.whiteboard.pojo.Room;
import org.apache.ibatis.annotations.Param;

/**
 * @Author: fan yang
 * @Description:
 */
public interface RoomMapper extends BaseMapper<Room> {

    /*
    * 新建房间表
    * */
    void createRoom(@Param(value = "room") Room room);

    /*
     * 插入一个新房间
     * */
    int insertRoom(@Param(value = "room") Room room);

}
