package com.xxxx.whiteboard.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.xxxx.whiteboard.pojo.User;

/**
 * @Author: fan yang
 * @Description:
 */
public interface UserMapper extends BaseMapper<User> {

    // 把user的操作次数加一，返回user的新操作次数
    int operationNumIncr(String userId);
}
