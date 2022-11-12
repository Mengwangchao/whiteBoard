package com.xxxx.whiteboard.util;

import com.xxxx.whiteboard.pojo.Color;
import com.xxxx.whiteboard.pojo.Point;
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
public class JsonGetter {
    private Color color;
    private Point point;
    private float lineWidth;
    private String userId;
    private String roomId;
    private int authority;
    private int pageCount;
    private int currentPage;
    private int graphical;

}
