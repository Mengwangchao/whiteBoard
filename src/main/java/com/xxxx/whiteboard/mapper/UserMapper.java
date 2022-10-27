package com.xxxx.whiteboard.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.xxxx.whiteboard.entity.User;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

/**
 * @Author: fan yang
 * @Description:
 */
public interface UserMapper extends BaseMapper<User>{
    /**
     * 获取所有用户
     */
    //List<User> findAllUsers();
}
