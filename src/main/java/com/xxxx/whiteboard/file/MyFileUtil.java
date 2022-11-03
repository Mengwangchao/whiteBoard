package com.xxxx.whiteboard.file;

import cn.hutool.core.io.FileUtil;
import cn.hutool.core.util.CharsetUtil;
import cn.hutool.json.JSONArray;
import cn.hutool.json.JSONUtil;
import com.xxxx.whiteboard.pojo.Point;
import org.apache.commons.io.FileUtils;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * @Author: fan yang
 * @Description:
 */
public class MyFileUtil {

    /**
     * 指定路径和文件名 生成.json格式文件
     */
    public static boolean createJsonFile(String filePath, String fileName) {
        // 标记文件生成是否成功
        boolean flag = true;

        // 拼接文件完整路径
        String fullPath = filePath + File.separator + fileName + ".json";

        try {
            // 生成json格式文件
            File file = new File(fullPath);
            if (!file.getParentFile().exists()) { // 如果父目录不存在，创建父目录
                file.getParentFile().mkdirs();
            }
            if (!file.exists()) {
                file.delete();
            }
            file.createNewFile();

        } catch (IOException e) {
            flag = false;
            e.printStackTrace();
        }

        // 返回是否成功的标记
        return flag;
    }

    /*
    * 把指定字符串写入到json文件
    * */
    public static boolean writeToJsonFile(String filePath, String fileName, String jsonString) {

        // 标记文件生成是否成功
        boolean flag = true;

        // 拼接文件完整路径
        String fullPath = filePath + File.separator + fileName + ".json";
        File file = new File(fullPath);

        // 格式化json字符串
        jsonString = JsonFormatTool.formatJson(jsonString);

        // 将格式化的字符串写入文件
        Writer write = null;
        try {
            write = new OutputStreamWriter(new FileOutputStream(file), "utf-8");
            write.write(jsonString);
            write.flush();
            write.close();
        } catch (UnsupportedEncodingException e) {
            flag = false;
            e.printStackTrace();
        } catch (FileNotFoundException e) {
            flag = false;
            e.printStackTrace();
        } catch (IOException e) {
            flag = false;
            e.printStackTrace();
        }
        return flag;
    }

    /*
    * 读取json对象，放入JSONArray
    * */



}
