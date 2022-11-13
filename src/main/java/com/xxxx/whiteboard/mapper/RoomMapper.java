package com.xxxx.whiteboard.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.xxxx.whiteboard.pojo.Room;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

/**
 * @Author: fan yang
 * @Description:
 */
@Repository
public interface RoomMapper extends BaseMapper<Room> {

    //  房间里人数属性++
    void personNumIncr(@Param("roomId") String roomId);

    // 房间里人数 --
    void personNumDecr(@Param("roomId") String roomId);

    // 在room中将总页数 --
    void roomPageDecr(@Param("roomId") String roomId);

    // 在room中将总页数 ++
    void roomPageIncr(@Param("roomId") String roomId);

    // 添加房间
    void insertRoom(@Param("room") Room room);
}
