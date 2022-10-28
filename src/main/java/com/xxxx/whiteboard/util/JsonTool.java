package com.xxxx.whiteboard.util;

import com.xxxx.whiteboard.entity.Color;
import com.xxxx.whiteboard.entity.Point;
import org.json.JSONException;
import org.json.JSONObject;
/**
 * @Author: fan yang
 * @Description: 完成不同主题接口json数据的解析处理
 */
public class JsonTool {

    /*
    * 完成接口主题touchStart的数据解析
    * */
    public void touchStartDecoding(JSONObject startJson) throws JSONException {
        startJson.get("userId");
        startJson.get("roomId");
        Color color = JsonSubTool.getColor((JSONObject) startJson.get("color"));
        Point point = JsonSubTool.getPoint((JSONObject) startJson.get("point"), color);
    }
}
