package com.xxxx.whiteboard.validator;

import org.thymeleaf.util.StringUtils;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @Author: fan yang
 * @Description:
 */
public class ValidatorUtil {
    private static final Pattern roomId_Patten = Pattern.compile("^\\d{12}$");

    /*
    * roomId的校验
    * */
    public static boolean isRoomId(String roomId){
        if (StringUtils.isEmpty(roomId)){
            return false;
        }
        Matcher matcher = roomId_Patten.matcher(roomId);
        return matcher.matches();
    }
}
