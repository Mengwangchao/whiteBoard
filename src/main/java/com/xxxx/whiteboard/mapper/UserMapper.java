package com.xxxx.whiteboard.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.xxxx.whiteboard.pojo.User;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

/**
 * @Author: fan yang
 * @Description:
 */
@Repository
public interface UserMapper extends BaseMapper<User> {

    // 把user的操作次数加一，返回user的新操作次数
    int operationNumIncr(String userId);
}
