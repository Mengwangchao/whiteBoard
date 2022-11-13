package com.xxxx.whiteboard.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

/**
 * @Author: fan yang
 * @Description: point实体类
 */
@Data
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class Point {
    private float x;
    private float y;
    private int colorId;
    private int operationId;
}
