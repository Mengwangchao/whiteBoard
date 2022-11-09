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
    Color color;
    Point point;
    int authority; // 当前房间的模式
    int currentPage; // 删除也用这个currentPage得了
    float lineWidth;  // 线条粗细
    int graphical; // 图形id
    int pageCount; // 总页数


}
