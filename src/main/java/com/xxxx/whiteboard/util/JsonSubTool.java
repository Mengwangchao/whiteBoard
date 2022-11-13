package com.xxxx.whiteboard.util;

import com.xxxx.whiteboard.pojo.Color;
import com.xxxx.whiteboard.pojo.Image;
import com.xxxx.whiteboard.pojo.ImagePoint;
import com.xxxx.whiteboard.pojo.Point;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * @Author: fan yang
 * @Description:
 */
public class JsonSubTool {

    public static JsonPojo initJsonOj(JSONObject jsonObject, boolean multiParams) throws JSONException {
        JsonPojo jg = new JsonPojo();
        if (jsonObject.has("userId")) jg.setUserId((String) jsonObject.get("userId"));
        if (jsonObject.has("roomId")) jg.setRoomId((String) jsonObject.get("roomId"));
        if (!multiParams) return jg; // 如果只有前两项，直接返回
        if (jsonObject.has("authority")) jg.setAuthority((int) jsonObject.get("authority"));
        if (jsonObject.has("currentPage")) jg.setCurrentPage((int) jsonObject.get("currentPage"));
        if (jsonObject.has("lineWidth")) jg.setLineWidth((float) jsonObject.get("lineWidth"));
        if (jsonObject.has("graphical")) jg.setGraphical((int) jsonObject.get("graphical"));
        if (jsonObject.has("color")) jg.setColor(JsonSubTool.getColor((JSONObject) jsonObject.get("color")));
        if (jsonObject.has("pageCount")) jg.setPageCount((int) jsonObject.get("pageCount"));
        if (jsonObject.has("point"))
            jg.setPoint(JsonSubTool.getPoint((JSONObject) jsonObject.get("point"), jg.getColor(), jg.getGraphical(), jg.getLineWidth()));
        return jg;
    }

    /*
    * 直接转换成image对象
    * */
    public static Image initJsonOjAdv(JSONObject jo, boolean isMidXY) throws JSONException {
        Image img = new Image();
        if (jo.has("imageNum")) img.setImageNum((int) jo.get("imageNum"));
        if (jo.has("roomId")) img.setUserId((String) jo.get("userId"));
        if (jo.has("userId")) img.setUserId((String) jo.get("userId"));
        if (jo.has("imageId")) img.setImageId((int) jo.get("imageId"));
        if (jo.has("currentPage")) img.setCurrentPage((int) jo.get("currentPage"));
        if (jo.has("point")) {
            ImagePoint ipoint= (ImagePoint) jo.get("point");
            if (!isMidXY){
                img.setX(ipoint.getX());
                img.setY(ipoint.getY());
            }
            else {
                img.setMidX(ipoint.getX());
                img.setMidY(ipoint.getY());
            }
        }
        if (jo.has("rotate")) img.setRotate((float) jo.get("rotate"));
        return img;
    }

    /*
     * 从JsonObject获取到Color对象，并封装
     * */
    static Color getColor(JSONObject colorJson) throws JSONException {
        float a = (float) colorJson.get("a");
        float b = (float) colorJson.get("b");
        float g = (float) colorJson.get("g");
        float r = (float) colorJson.get("r");
        return new Color(r, g, b, a, -1);
    }

    /*
     * 从JsonObject获取到Color，并封装
     * */
    static Point getPoint(JSONObject pointJson, Color color, int graphical, float lineWidth) throws JSONException {
        float x = (float) pointJson.get("x");
        float y = (float) pointJson.get("y");
        return new Point(x, y, -1, -1);
    }

    static ImagePoint getImagePoint(JSONObject pointJson) throws JSONException {
        float x = (float) pointJson.get("x");
        float y = (float) pointJson.get("y");
        return new ImagePoint(x, y);
    }


}
