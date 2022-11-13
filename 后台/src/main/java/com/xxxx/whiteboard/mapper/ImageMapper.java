package com.xxxx.whiteboard.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.xxxx.whiteboard.pojo.Image;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

/**
 * @Author: fan yang
 * @Description:
 */
@Repository
public interface ImageMapper extends BaseMapper<Image> {

    /*
    * 保守修改update
    * */
    void updateSoftByNumId(@Param("image") Image image);
    //void insertImageAndUpdateNum(@Param("image") Image image);
    //
    //void updateByOperationId(@Param("operationId") int operationId, @Param("image") Image image);
    //
    //void updateNumByCount(Image img);
}
