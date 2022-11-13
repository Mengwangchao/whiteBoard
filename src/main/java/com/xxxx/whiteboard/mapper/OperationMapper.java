package com.xxxx.whiteboard.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.xxxx.whiteboard.pojo.Operation;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import javax.annotation.Resource;

/**
 * @Author: fan yang
 * @Description:
 */
@Repository
public interface OperationMapper extends BaseMapper<Operation> {
    /*
    *  删除掉operation中所有操作（可以，但没必要）
    * */
    void deleteByUserId(@Param("userId") String userId);

    /*
    * 删除掉operation中此房间的所有操作
    * */
    void deleteByRoomId(@Param("roomId") String roomId);

    /*
    * 删除掉某房间某页数的所有操作
    * */
    void deleteByCurrentPage(String roomId, int currentPage);

    /*
    * 将所有大于对应currentPage的currentPage的递减
    * */
    void biggerCurrentPageDecr(String roomId, int currentPage);
}
