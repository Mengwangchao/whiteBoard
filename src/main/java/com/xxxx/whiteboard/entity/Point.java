package com.xxxx.whiteboard.entity;

import lombok.Data;


/**
 * @Author: fan yang
 * @Description: 组成路径的坐标点
 */
@Data
public class Point {
    /** x轴坐标值 */
    private float x;
    /** y轴坐标值 */
    private float y;
    /** 坐标点颜色 */
    private Color pointColor;

}
