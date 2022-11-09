package com.xxxx.whiteboard.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;
import org.hibernate.validator.constraints.Length;
import org.hibernate.validator.constraints.Range;

import javax.validation.constraints.NotNull;

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
    @NotNull
    @Length(min = 12, max = 12)
    private String roomId; //  房间id：123456789011

    /** 房间状态 */
    private int roomState; // 房间状态

    /** 房间模式 */
    @Range(min = 1, max = 2)
    private int authority = 1; // 模式：1代表协作，2代表只读

    /** 房间总页数 */
    private int pageCount;

    /** 当前页数 */
    private int currentPage;

    ///* 房间总共人数 */
    //private int peopleNum;
}
