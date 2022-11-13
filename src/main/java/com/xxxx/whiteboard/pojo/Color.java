package com.xxxx.whiteboard.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

/**
 * @Author: fan yang
 * @Description: 颜色实体类
 */
@Data
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class Color {
    private float r;
    private float g;
    private float b;
    private float a;
    private int colorId; // color_id
}
