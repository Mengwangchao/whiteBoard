package com.xxxx.whiteboard.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.xxxx.whiteboard.pojo.Room;
import org.apache.ibatis.annotations.Param;

/**
 * @Author: fan yang
 * @Description:
 */
public interface RoomMapper extends BaseMapper<Room> {

    //  房间里人数属性++
    void personNumIncr(@Param("roomId") String roomId);

    // 房间里人数 --
    void personNumDecr(@Param("roomId") String roomId);

    // 在room中将总页数 --
    void roomPageDecr(@Param("roomId") String roomId);

    // 在room中将总页数 ++
    void roomPageIncr(@Param("roomId") String roomId);
}
