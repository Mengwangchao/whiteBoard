package com.xxxx.whiteboard.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.xxxx.whiteboard.pojo.User;
import com.xxxx.whiteboard.mapper.UserMapper;
import com.xxxx.whiteboard.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * @Author: fan yang
 * @Description:
 */
@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    @Autowired(required = false)
    private UserMapper userMapper;


    //public static void main(String[] args) {
    //    UserMapper userMapper = null;
    //    User user = new User("123","456");
    //    userMapper.insert(user);
    //}
}
