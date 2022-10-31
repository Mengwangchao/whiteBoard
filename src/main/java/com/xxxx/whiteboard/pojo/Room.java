package com.xxxx.whiteboard.pojo;

import com.baomidou.mybatisplus.annotation.TableName;
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
@NoArgsConstructor
@AllArgsConstructor
public class Room {

    /** 房间号 */
    private String roomId; //  房间id：123456789011

    /** 房间状态 */
    private int roomState; // 房间状态

    /** 房间模式 */
    private int authority; // 模式：写作和只读
}
