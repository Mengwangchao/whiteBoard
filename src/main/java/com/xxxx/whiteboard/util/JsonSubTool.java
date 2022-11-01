package com.xxxx.whiteboard.util;

import com.xxxx.whiteboard.pojo.Color;
import com.xxxx.whiteboard.pojo.JsonGetter;
import com.xxxx.whiteboard.pojo.Point;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * @Author: fan yang
 * @Description: 从Json串中解析常用类
 */
public class JsonSubTool {


    /*
     * 对所有json信息的预处理
     * 如果只有userId和roomId, flag = false, 否则flag = true
     * */
    public static JsonGetter initJsonObject(JSONObject jsonObject, boolean multiParams) throws JSONException {
        JsonGetter jsonGetter = new JsonGetter();
        if (jsonObject.has("userId")) jsonGetter.setUserId((String) jsonObject.get("userId"));
        if (jsonObject.has("roomId")) jsonGetter.setRoomId((String) jsonObject.get("roomId"));
        if (!multiParams) return jsonGetter; // 如果只有前两项，直接返回
        if (jsonObject.has("authority")) jsonGetter.setAuthority((int) jsonObject.get("authority"));
        if (jsonObject.has("currentPage")) jsonGetter.setCurrentPage((int) jsonObject.get("currentPage"));
        if (jsonObject.has("color")) jsonGetter.setColor(JsonSubTool.getColor((JSONObject) jsonObject.get("color")));
        if (jsonObject.has("point")) jsonGetter.setPoint(JsonSubTool.getPoint((JSONObject) jsonObject.get("point"), jsonGetter.getColor()));
        return jsonGetter;
    }

    /*
     * 从JsonObject获取到Color对象，并封装
     * */
    static Color getColor(JSONObject colorJson) throws JSONException {
        float a = (float) colorJson.get("a");
        float b = (float) colorJson.get("b");
        float g = (float) colorJson.get("g");
        float r = (float) colorJson.get("r");
        return new Color(r, g, b, a);
    }

    /*
     * 从JsonObject获取到Color，并封装
     * */
    static Point getPoint(JSONObject pointJson, Color color) throws JSONException {
        float x = (float) pointJson.get("x");
        float y = (float) pointJson.get("y");
        return new Point(x, y, color);
    }





}
