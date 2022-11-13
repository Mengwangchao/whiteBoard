package com.xxxx.whiteboard.pojo;

import com.baomidou.mybatisplus.annotation.TableId;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

/**
 * @Author: fan yang
 * @Description: 房间实体类
 */
@Data
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class Room {
    @TableId
    private String roomId;
    private int pageCount;
    private int currentPage;
    private int peopleNum; // 房间人数
}
