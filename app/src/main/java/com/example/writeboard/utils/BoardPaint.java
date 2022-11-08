package com.example.writeboard.utils;

import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Xfermode;

import com.example.writeboard.view.PaletteView;

public class BoardPaint extends Paint {
//    设置单例模式
    private volatile static BoardPaint mBoardPaint;

    //  画笔属性
    private static float mDrawSize;
    private static float mEraserSize;
    private static Xfermode mClearMode;
    public static enum Mode {
        DRAW,
        ERASER
    }
    private static Mode mMode = Mode.DRAW;
    private static void initPaint() {
        mDrawSize = 10;
        mEraserSize = 10;
        mBoardPaint.setStyle(Paint.Style.STROKE);
        mBoardPaint.setFilterBitmap(true);
        mBoardPaint.setStrokeJoin(Paint.Join.ROUND);
        mBoardPaint.setStrokeCap(Paint.Cap.ROUND);
        mBoardPaint.setStrokeWidth(mDrawSize);
        mBoardPaint.setARGB(255, 0, 0, 0);
        mClearMode = new PorterDuffXfermode(PorterDuff.Mode.CLEAR);

    }
    public static BoardPaint getmBoardPaint(){
        if(mBoardPaint==null){
            synchronized (BoardPaint.class){
                if(mBoardPaint==null){
                    mBoardPaint=new BoardPaint(Paint.ANTI_ALIAS_FLAG | Paint.DITHER_FLAG);
                    initPaint();
                }
            }
        }


        return mBoardPaint;
    }

    private BoardPaint() {
    }

    private BoardPaint(int flags) {
        super(flags);
    }

    private BoardPaint(Paint paint) {
        super(paint);
    }

    /**
     * @return return Mode
     */
    public Mode getMode() {
        return mMode;
    }

    /**
     * @param mode set Mode
     */
    public void setMode(Mode mode) {
        if (mode != mMode) {
            mMode = mode;
            if (mMode == Mode.DRAW) {
                mBoardPaint.setXfermode(null);
                mBoardPaint.setStrokeWidth(mDrawSize);
            } else {
                mBoardPaint.setXfermode(mClearMode);
                mBoardPaint.setStrokeWidth(mEraserSize);
            }
        }
    }

    /**
     * @param size Change Eraser Size
     */
    public void setEraserSize(float size) {
        mEraserSize = size;
        mBoardPaint.setStrokeWidth(mEraserSize);
    }

    /**
     * @param size Change Pen Size
     */
    public void setPenRawSize(float size) {
        mDrawSize = size;
        mBoardPaint.setStrokeWidth(mDrawSize);
    }

    /**
     * @param colors Change Pen Color
     */
    public void setPenColor(int colors[]) {
        mBoardPaint.setARGB(colors[0], colors[1], colors[2], colors[3]);
    }

    /**
     * @return return pen color
     */
    public int getPenColor() {
        return mBoardPaint.getColor();
    }

}
