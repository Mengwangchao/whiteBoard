package com.xxxx.whiteboard.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

/**
 * @Author: fan yang
 * @Description:
 */
@Data
@ToString
@AllArgsConstructor
@NoArgsConstructor
public class JsonGetter {
    String userId;
    String roomId;
    int authority; // 当前房间的模式
    int currentPage; // 删除也用这个currentPage得了
    Color color;
    Point point;
}
