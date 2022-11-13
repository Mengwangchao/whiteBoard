package com.example.writeboard.utils;

import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Xfermode;

import com.example.writeboard.view.PaletteView;

public class BoardPaint extends Paint {
    private volatile static BoardPaint mBoardPaint;
    private static float mDrawSize;
    private static float mEraserSize;
    private static Xfermode mClearMode;
    public int[] color = new int[]{255, 0, 0, 0};
    public static enum Mode {
        DRAW,
        ERASER
    }
    private static Mode mMode = Mode.DRAW;

    float Figure[]=new float[]{1,2,3};
    float figure=Figure[0];


    public float getFigure() {
        return figure;
    }

    public void setFigure(float figure) {
        this.figure = figure;
    }

    private static void initPaint() {
        mDrawSize = 10;
        mEraserSize = 10;
        mBoardPaint.setStyle(Style.STROKE);
        mBoardPaint.setFilterBitmap(true);
        mBoardPaint.setStrokeJoin(Paint.Join.ROUND);
        mBoardPaint.setStrokeCap(Paint.Cap.ROUND);
        mBoardPaint.setStrokeWidth(mDrawSize);
        mBoardPaint.setARGB(255, 0, 0, 0);
        mClearMode = new PorterDuffXfermode(PorterDuff.Mode.CLEAR);
    }

    public static BoardPaint getmBoardPaint() {

        if (mBoardPaint == null) {
            synchronized (BoardPaint.class) {
                if (mBoardPaint == null) {
                    mBoardPaint = new BoardPaint(Paint.ANTI_ALIAS_FLAG | Paint.DITHER_FLAG);
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

    public float getPenRawSize() {
        return mDrawSize;
    }

    /**
     * @param a aphle
     * @param r red
     * @param g green
     * @param b blue
     */
    public void setPenColor(int a, int r, int g, int b) {
        color[0] = a;
        color[1] = r;
        color[2] = g;
        color[3] = b;
        mBoardPaint.setARGB(a, r, g, b);
    }

    /**
     * @return return pen color
     */
    public int getPenColor() {
        return mBoardPaint.getColor();
    }
}
