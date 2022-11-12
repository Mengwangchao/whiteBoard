package com.xxxx.whiteboard.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.xxxx.whiteboard.pojo.Color;
import org.apache.ibatis.annotations.Param;

/**
 * @Author: fan yang
 * @Description:
 */
public interface ColorMapper extends BaseMapper<Color> {

    // 查询是否存在这个颜色, 如果存在返回colorId, 如果不存在返回0
    int getColorId(@Param("r") float r, @Param("g") float g, @Param("b") float b, @Param("a") float a);
}
