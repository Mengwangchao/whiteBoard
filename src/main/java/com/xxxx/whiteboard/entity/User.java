package com.xxxx.whiteboard.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

/**
 * @Author: fan yang
 * @Description: 用户类
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
@TableName("user")
public class User {
    /** 用户的id */
    private String userId; // user1666843216

    /** 用户的room */
    private String roomId;



}
