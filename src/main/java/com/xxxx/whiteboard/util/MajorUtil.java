package com.xxxx.whiteboard.util;

import java.util.HashMap;
import java.util.Map;

/**
 * @Author: fan yang
 * @Description:
 */
public class MajorUtil {

    /*
    为了使用户的每次操作标志为同一次: 例如touchStart、touching、touchEnd都算上
    保存操作id
    */
    public static Map<String, Integer> map = new HashMap<>(); // 新建一个map

    /*
    根据roomId和CurrentPage获取表名
    */
    public static String getTableName(String roomId, int currentPage) {
        String tableName = "r" + roomId.substring(0, 4) + "p" + currentPage;
        return tableName;
    }





}
