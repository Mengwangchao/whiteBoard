package com.xxxx.whiteboard.util;

import com.xxxx.whiteboard.pojo.Color;
import com.xxxx.whiteboard.pojo.Point;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * @Author: fan yang
 * @Description: 从Json串中解析常用类
 */
public class JsonSubTool {

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
