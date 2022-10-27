package com.xxxx.whiteboard;

import com.xxxx.whiteboard.entity.User;
import com.xxxx.whiteboard.mapper.UserMapper;
import com.xxxx.whiteboard.service.UserService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.Arrays;
import java.util.List;

@SpringBootTest
class WhiteBoardApplicationTests {

    //private UserService userService;

    @Autowired(required = false)
    private UserMapper userMapper;

    @Test
    void addUserTest() {
        //List<User> users = userService.findAllUsers();
        //System.out.println(Arrays.toString(new List[]{users}));
        User user1 = new User("1314", "12121");
        userMapper.insert(user1);
    }

}
