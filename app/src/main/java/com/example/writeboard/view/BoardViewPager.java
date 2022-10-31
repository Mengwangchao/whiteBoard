package com.example.writeboard.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.viewpager.widget.ViewPager;

public class BoardViewPager extends ViewPager {
    private boolean canSwipe=true;

    public BoardViewPager(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public BoardViewPager(@NonNull Context context) {
        super(context);
    }
    public void setIsSwipe(boolean canSwipe){
        this.canSwipe=canSwipe;
    }

    @Override
    public boolean onTouchEvent(MotionEvent ev) {
        return canSwipe &&super.onTouchEvent(ev);
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        return canSwipe&& super.onInterceptTouchEvent(ev);
    }
}
