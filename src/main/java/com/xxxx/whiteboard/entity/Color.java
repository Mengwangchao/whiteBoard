package com.xxxx.whiteboard.entity;

import lombok.Data;
import org.springframework.boot.jackson.JsonComponent;

/**
 * @Author: fan yang
 * @Description: Color类，rgba格式的颜色
 */
@Data
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
