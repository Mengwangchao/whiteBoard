package com.xxxx.whiteboard.mapper;

import org.apache.ibatis.annotations.Param;

/**
 * @Author: fan yang
 * @Description:
 */
public interface RoomMapper {

    /*
    以roomId作表名，建立一个新房间的空表
    * */
    void createRoom(@Param(value = "roomId") String roomId);


}
