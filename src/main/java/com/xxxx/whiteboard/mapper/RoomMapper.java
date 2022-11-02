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
    * 建立某roomId, 某currentPage下的表：用来存储所有point
    * */
    void createPage(@Param("roomId") String roomId, @Param("currentPage") int currentPage);

    /*
     * 插入一个新房间
     * */
    int createRoom(@Param("room") Room room);

    /*
     * 改变roomState
     * */
    int setRoomState(@Param("roomId") String roomId, @Param("roomState") int roomStatus);


    /*
     * 删除掉某个room某个page
     * */
    int deletePageOfRoom(@Param("roomId") String roomId, @Param("pageNo") int pageNo);



}
