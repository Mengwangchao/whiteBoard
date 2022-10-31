package com.example.writeboard.adapter;

import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.viewpager.widget.PagerAdapter;
import androidx.viewpager.widget.ViewPager;

import com.example.writeboard.view.PaletteView;

import java.util.ArrayList;

public class BoardAdapter extends PagerAdapter {


    private ArrayList<PaletteView> listViews;// content

    private int size;// 页数

    public BoardAdapter(ArrayList<PaletteView> listViews) {// 构造函数
        // 初始化viewpager的时候给的一个页面
        this.listViews = listViews;
        size = listViews == null ? 0 : listViews.size();
    }

    public void setListViews(ArrayList<PaletteView> listViews) {// 自己写的一个方法用来添加数据  这个可是重点啊
        this.listViews = listViews;
        size = listViews == null ? 0 : listViews.size();
    }

    @Override
    public int getCount() {// 返回数量
        return size;
    }

    @Override
    public void destroyItem(View arg0, int arg1, Object arg2) {// 销毁view对象
        ((ViewPager) arg0).removeView(listViews.get(arg1 % size));
    }

    @Override
    public void finishUpdate(View arg0) {
    }

    @Override
    public Object instantiateItem(View arg0, int arg1) {// 返回view对象
        try {
            ((ViewPager) arg0).addView(listViews.get(arg1 % size), 0);
        } catch (Exception e) {
            Log.e("zhou", "exception：" + e.getMessage());
        }
        return listViews.get(arg1 % size);
    }

    @Override
    public boolean isViewFromObject(View arg0, Object arg1) {
        return arg0 == arg1;
    }


}
