package com.example.writeboard.utils;

import android.content.Context;

public class DrawUtils {
    public static float dptopx(Context context,int dp){
        return context.getResources().getDisplayMetrics().density*dp;
    }
}
