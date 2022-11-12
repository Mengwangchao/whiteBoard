package com.xxxx.whiteboard.pojo;

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
    private String roomId;
    private int currentPage;
    private int pageCount;
    private int peopleNum; // 房间人数
}
