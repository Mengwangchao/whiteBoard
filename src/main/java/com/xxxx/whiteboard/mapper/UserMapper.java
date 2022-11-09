package com.xxxx.whiteboard.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.xxxx.whiteboard.pojo.User;
import org.apache.ibatis.annotations.Param;

/**
 * @Author: fan yang
 * @Description:
 */
public interface UserMapper extends BaseMapper<User>{
    /**
     * 获取所有用户
     */
    //List<User> findAllUsers();

    /*
    获取房间的人数
    * */
    int selectCount(@Param("roomId") String roomId);
}
