package com.xxxx.whiteboard.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

/**
 * @Author: fan yang
 * @Description: Color类，rgba格式的颜色
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class Color {
    // 参数 r
    private float r;
    // 参数 g
    private float g;
    // 参数 b
    private float b;
    // 参数 a
    private float a;
}
