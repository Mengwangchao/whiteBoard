package com.xxxx.whiteboard.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

/**
 * @Author: fan yang
 * @Description: 用户实体类
 */
@Data
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class User {
    private String userId;
    private String roomId; // count(*) where roomId = 啥
    private int authority;
    private int operationNum; // 这个是这个用户操作的表名,操作次数
}
