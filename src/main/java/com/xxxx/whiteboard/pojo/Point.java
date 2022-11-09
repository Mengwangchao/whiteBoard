package com.xxxx.whiteboard.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;


/**
 * @Author: fan yang
 * @Description: 组成路径的坐标点
 */
@Data
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class Point {
    /** x轴坐标值 */
    private float x;
    /** y轴坐标值 */
    private float y;
    /** 坐标点颜色 */
    private Color pointColor;

    /* 图形id */
    private int graphical;

    /* 线条粗细 */
    private float lineWidth;

}
