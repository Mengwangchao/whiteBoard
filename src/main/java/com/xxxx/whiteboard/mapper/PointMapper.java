package com.xxxx.whiteboard.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.xxxx.whiteboard.pojo.Point;
import org.apache.ibatis.annotations.Param;

/**
 * @Author: fan yang
 * @Description:
 */
public interface PointMapper extends BaseMapper<Point> {

    /*
    保存点
    * */
    void savePoint(@Param("roomId") String roomId, @Param("currentPage") int currentPage, @Param("point") Point point);
}
