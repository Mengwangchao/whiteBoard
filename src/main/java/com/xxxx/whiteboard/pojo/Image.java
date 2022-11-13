package com.xxxx.whiteboard.pojo;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

/**
 * @Author: fan yang
 * @Description: image实体类，和数据表对应
 */
@Data
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class Image {
    @TableId(type = IdType.AUTO) // 主键生成自增
    private int imageNum;
    private String roomId;
    private String userId;
    private int imageId;
    private int currentPage;
    private float x;
    private float y;
    private boolean locked; // true 或者 false
    private int operationId;
    private float midX;
    private float midY;
    private float rotate; // 旋转角度
}
