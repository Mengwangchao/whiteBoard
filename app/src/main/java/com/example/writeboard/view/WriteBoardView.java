package com.example.writeboard.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;

import androidx.annotation.Nullable;

public class WriteBoardView extends View {

    private  Context context;
    private Path mPath;
    private Paint mPaint;

    public WriteBoardView(Context context) {
        super(context);
    }

    public WriteBoardView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public WriteBoardView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public WriteBoardView(Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }


    @Override
    public boolean onTouchEvent(MotionEvent event) {
        return super.onTouchEvent(event);


    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

    }
   void init(){
        mPath=new Path();
        mPaint=new Paint(Paint.ANTI_ALIAS_FLAG);

    }
}
