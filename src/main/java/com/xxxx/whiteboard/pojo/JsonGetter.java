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
    int currentPage;
    Color color;
    Point point;
}
