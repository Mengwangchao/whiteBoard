package com.xxxx.whiteboard.pojo;

import com.baomidou.mybatisplus.annotation.TableId;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

/**
 * @Author: fan yang
 * @Description: 这个就记录所有用户的operation作为一个list
 * 操作实体类
 */
@Data
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class Operation {
    private String user_id; // 用户id
    private String room_id; // 哪个房间进行的操作
    private int currentPage; // 每个操作在哪个页面
    private String table_Name; // 这个是针对每一个room每一个page而言的
    private int graphical; // 操作类型
    private float lineWidth; // 每一个操作的线宽是一致的
    private int hidden; // 这个操作是否被隐藏了
    private int colorId; // 每次操作的颜色也是一致的
    private int operationId; // 操作id

    // 点集可以使用 GROUP BY使用operation_id进行归类
    // undo找到
}
