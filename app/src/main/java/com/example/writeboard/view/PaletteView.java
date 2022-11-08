package com.example.writeboard.view;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorSpace;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Xfermode;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.Nullable;

import com.example.writeboard.utils.BoardPaint;
import com.example.writeboard.utils.MqttClient;

import java.util.ArrayList;
import java.util.List;

public class PaletteView extends View {

    private BoardPaint mBoardPaint;
    //    画笔
//    private Paint mPaint;
    //    路径
    private Path mPath;
    //    上一个点的X，Y值
    private float mLastX;
    private float mLastY;
    //     保存的的bitmap
    private Bitmap mBufferBitmap;
    //    画布
    private Canvas mBufferCanvas;
    //    mqtt client（每张画布所持有的唯一的一个mqttClient实例）
    private MqttClient mqttClient;
    //    最大的保存步骤（多余的步骤返回不了，防止占用内存太大）
    private static final int MAX_CACHE_STEP = 20;
    //    划线的步骤
    private List<DrawingInfo> mDrawingList;
    //    移除的步骤
    private List<DrawingInfo> mRemovedList;
    //    橡皮擦模式
    private Xfermode mClearMode;
    //    画笔粗细
    private float mDrawSize;
    //    橡皮擦粗细
    private float mEraserSize;
    //    是否可擦除
    private boolean mCanEraser;
    //    callback
    private Callback mCallback;
    public enum Mode {
        DRAW,
        ERASER
    }
    private Mode mMode = Mode.DRAW;

    public void setmBoardPaint(BoardPaint mBoardPaint) {
        this.mBoardPaint = mBoardPaint;
    }

    public PaletteView(Context context) {
        this(context, null);
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("xiaohao");
        context.registerReceiver(broadcastReceiver, intentFilter);

    }

    public PaletteView(Context context, AttributeSet attrs) {
        super(context, attrs);
        setDrawingCacheEnabled(true);
//        init();
    }


//设置mqttclient，用于每个操作进行发送消息
    public void setMqttClient(MqttClient mqttClient) {
        this.mqttClient = mqttClient;
    }
//设置画笔进行绘制
    public void setBoardPaint(BoardPaint boardPaint) {
        this.mBoardPaint = boardPaint;
    }

    public interface Callback {
        void onUndoRedoStatusChanged();
    }

    public void setCallback(Callback callback) {
        mCallback = callback;
    }


    private void initBuffer() {
        mBufferBitmap = Bitmap.createBitmap(getWidth(), getHeight(), Bitmap.Config.ARGB_8888);
        mBufferCanvas = new Canvas(mBufferBitmap);
    }

    private abstract static class DrawingInfo {
        Paint Paint;

        abstract void draw(Canvas canvas);
    }

    private static class PathDrawingInfo extends DrawingInfo {

        Path path;

        @Override
        void draw(Canvas canvas) {
            canvas.drawPath(path, Paint);
        }
    }




    public boolean canRedo() {
        return mRemovedList != null && mRemovedList.size() > 0;
    }

    public boolean canUndo() {
        return mDrawingList != null && mDrawingList.size() > 0;
    }


    private void reDraw() {
        if (mDrawingList != null) {
            mBufferBitmap.eraseColor(Color.TRANSPARENT);
            for (DrawingInfo drawingInfo : mDrawingList) {
                drawingInfo.draw(mBufferCanvas);
            }
            invalidate();
        }
    }

    public void redo() {
        int size = mRemovedList == null ? 0 : mRemovedList.size();
        if (size > 0) {
            DrawingInfo info = mRemovedList.remove(size - 1);
            mDrawingList.add(info);
            mCanEraser = true;
            reDraw();
            if (mCallback != null) {
                mCallback.onUndoRedoStatusChanged();
            }
        }
    }

    public void undo() {
        int size = mDrawingList == null ? 0 : mDrawingList.size();
        if (size > 0) {
            DrawingInfo info = mDrawingList.remove(size - 1);
            if (mRemovedList == null) {
                mRemovedList = new ArrayList<>(MAX_CACHE_STEP);
            }
            if (size == 1) {
                mCanEraser = false;
            }
            mRemovedList.add(info);
            reDraw();
            if (mCallback != null) {
                mCallback.onUndoRedoStatusChanged();
            }
        }
    }

    public void clear() {
        if (mBufferBitmap != null) {
            if (mDrawingList != null) {
                mDrawingList.clear();
            }
            if (mRemovedList != null) {
                mRemovedList.clear();
            }
            mCanEraser = false;
            mBufferBitmap.eraseColor(Color.TRANSPARENT);
            invalidate();
            if (mCallback != null) {
                mCallback.onUndoRedoStatusChanged();
            }
        }
    }

    public Bitmap buildBitmap() {
        Bitmap bm = getDrawingCache();
        Bitmap result = Bitmap.createBitmap(bm);
        destroyDrawingCache();
        return result;
    }

    private void saveDrawingPath() {
        if (mDrawingList == null) {
            mDrawingList = new ArrayList<>(MAX_CACHE_STEP);
        } else if (mDrawingList.size() == MAX_CACHE_STEP) {
            mDrawingList.remove(0);
        }
        Path cachePath = new Path(mPath);
        Paint cachePaint = new Paint(mBoardPaint);
        PathDrawingInfo info = new PathDrawingInfo();
        info.path = cachePath;
        info.Paint = cachePaint;
        mDrawingList.add(info);
        mCanEraser = true;
        if (mCallback != null) {
            mCallback.onUndoRedoStatusChanged();
        }
    }

    @Override
    protected void onDraw(Canvas canvas) {
        if (mBufferBitmap != null) {
            canvas.drawBitmap(mBufferBitmap, 0, 0, null);
        }
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        final int action = event.getAction() & MotionEvent.ACTION_MASK;
        final float x = event.getX();
        final float y = event.getY();
        switch (action) {
            case MotionEvent.ACTION_DOWN:
                Log.i("Hve", "本地开始划线");

                mLastX = x;
                mLastY = y;
                if (mPath == null) {
                    mPath = new Path();
                }
//                设置初始点(线段的落笔点）
                mPath.moveTo(x, y);
                mqttClient.subscribe("touchStart");
//                mqttClient.publish("a/b", "{\n" +
//                        "\"mode\":\"" + 1 + "\",\n" +
//                        "\"a\":\"" + x + "\",\n" +
//                        "\"b\":\"" + y + "\",\n" +
//                        "\"id\":\"" + mqttClient.getUserId() + "\"\n" +
//                        "}", false);
                mqttClient.publish("touchStart", "{\n" +
                        "\"color\":{\n" +
                        "\"a\":" + "\"1.000000\"" + ",\n" +
                        "\"b\":" + "\"128.000000\"" + ",\n" +
                        "\"g\":" + "\"128.000000\"" + ",\n" +
                        "\"r\":" + "\"128.000000\"" + "\n" +
                        "},\n" +
                        "\"point\":{\n" +
                        "\"x\":" + "\"" + x + "\"" + ",\n" +
                        "\"y\":" + "\"" + y + "\"" + "\n" +
                        "},\n" +
                        "\"lineWidth\":" + "\"1.0\"" + ",\n" +
                        "\"userId\":" + "\"1.0\"" + ",\n" +
                        "\"roomId\":" + "\"149459955291\"" + ",\n" +
                        "\"currentPage\":" + "\"1.0\"" + ",\n" +
                        "\"graphical\":" + "\"1.0\"" + "\n" +
                        "}", false);
                break;
            case MotionEvent.ACTION_MOVE:
                Log.i("Hve", "本地划线中");

//                (x + mLastX) / 2 (y + mLastY) / 2
                //这里终点设为两点的中心点的目的在于使绘制的曲线更平滑，如果终点直接设置为x,y，效果和lineto是一样的,实际是折线效果
                mPath.quadTo(mLastX, mLastY, (x + mLastX) / 2, (y + mLastY) / 2);
//                mPath.lineTo(x,y);
                if (mBufferBitmap == null) {
                    initBuffer();
                }
                if (mMode == Mode.ERASER && !mCanEraser) {
                    break;
                }
                mBufferCanvas.drawPath(mPath, mBoardPaint);
                invalidate();
                mLastX = x;
                mLastY = y;
//                mqttClient.subscribe("a/b");
//                mqttClient.publish("a/b", "{\n" +
//                        "\"mode\":\"" + 2 + "\",\n" +
//                        "\"a\":\"" + x + "\",\n" +
//                        "\"b\":\"" + y + "\",\n" +
//                        "\"id\":\"" + mqttClient.getUserId() + "\"\n" +
//                        "}", false);
                mqttClient.subscribe("149459955291");
                mqttClient.publish("149459955291", "{\n" +
                        "\"color\":{\n" +
                        "\"a\":" + "\"1.000000\"" + ",\n" +
                        "\"b\":" + "\"128.000000\"" + ",\n" +
                        "\"g\":" + "\"128.000000\"" + ",\n" +
                        "\"r\":" + "\"128.000000\"" + "\n" +
                        "},\n" +
                        "\"point\":{\n" +
                        "\"x\":" + "\"" + x + "\"" + ",\n" +
                        "\"y\":" + "\"" + y + "\"" + "\n" +
                        "},\n" +
                        "\"lineWidth\":" + "\"1.0\"" + ",\n" +
                        "\"userId\":" + "\"1.0\"" + ",\n" +
                        "\"roomId\":" + "\"149459955291\"" + ",\n" +
                        "\"currentPage\":" + "\"1.0\"" + ",\n" +
                        "\"graphical\":" + "\"1.0\"" + "\n" +
                        "}", false);
                break;
            case MotionEvent.ACTION_UP:
                Log.i("Hve", "本地划线结束");

                if (mMode == Mode.DRAW || mCanEraser) {
                    saveDrawingPath();
//                    mqttClient.subscribe("a/b");
//                    mqttClient.publish("a/b", "{\n" +
//                            "\"mode\":\"" + 3 + "\",\n" +
//                            "\"a\":\"" + x + "\",\n" +
//                            "\"b\":\"" + y + "\",\n" +
//                            "\"id\":\"" + mqttClient.getUserId() + "\"\n" +
//                            "}", false);
                    mqttClient.subscribe("touchEnd");
                    mqttClient.publish("touchEnd", "{\n" +
                            "\"color\":{\n" +
                            "\"a\":" + "\"1.000000\"" + ",\n" +
                            "\"b\":" + "\"128.000000\"" + ",\n" +
                            "\"g\":" + "\"128.000000\"" + ",\n" +
                            "\"r\":" + "\"128.000000\"" + "\n" +
                            "},\n" +
                            "\"point\":{\n" +
                            "\"x\":" + "\"" + x + "\"" + ",\n" +
                            "\"y\":" + "\"" + y + "\"" + "\n" +
                            "},\n" +
                            "\"lineWidth\":" + "\"1.0\"" + ",\n" +
                            "\"userId\":" + "\"1.0\"" + ",\n" +
                            "\"roomId\":" + "\"149459955291\"" + ",\n" +
                            "\"currentPage\":" + "\"1.0\"" + ",\n" +
                            "\"graphical\":" + "\"1.0\"" + "\n" +
                            "}", false);
                }
                mPath.reset();
                break;
        }
        return true;
    }

    public void drawStart(float x, float y) {
        mLastX = x;
        mLastY = y;
        if (mPath == null) {
            mPath = new Path();
        }
        mPath.moveTo(x, y);
    }

    public void drawMove(float x, float y) {
        mPath.quadTo(mLastX, mLastY, (x + mLastX) / 2, (y + mLastY) / 2);
        if (mBufferBitmap == null) {
            initBuffer();
        }
        mBufferCanvas.drawPath(mPath, mBoardPaint);
        invalidate();
        mLastX = x;
        mLastY = y;
    }

    public void drawEnd(float x, float y) {
        saveDrawingPath();
        mPath.reset();

    }

    private BroadcastReceiver broadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals("xiaohao")) {

                Toast.makeText(context, "接收到消息了\n x值：" + intent.getFloatExtra("x", 0.0f) + "\n y值：" + intent.getFloatExtra("y", 0.0f) + "\n id值："
                        + intent.getStringExtra("id") + "\n mode:" + intent.getIntExtra("mode", 0), Toast.LENGTH_SHORT).show();

                int mode = intent.getIntExtra("mode", 0);
                if (mode == 1) {
                    Log.i("move", "开始划线");

                    drawStart(intent.getFloatExtra("x", 0.0f), intent.getFloatExtra("y", 0.0f));
                } else if (mode == 2) {
                    Log.i("move", "划线中");


                    drawMove(intent.getFloatExtra("x", 0.0f), intent.getFloatExtra("y", 0.0f));
                } else if (mode == 3) {
                    Log.i("move", "划线结束");

                    drawEnd(intent.getFloatExtra("x", 0.0f), intent.getFloatExtra("y", 0.0f));

                }
            }
        }
    };

//    public Mode getMode() {
//        return mMode;
//    }
//
//    public void setMode(Mode mode) {
//        if (mode != mMode) {
//            mMode = mode;
//            if (mMode == Mode.DRAW) {
//                mPaint.setXfermode(null);
//                mPaint.setStrokeWidth(mDrawSize);
//            } else {
//                mPaint.setXfermode(mClearMode);
//                mPaint.setStrokeWidth(mEraserSize);
//            }
//        }
//    }
//
//
//
//    public void setPenAlpha(int alpha) {
//        mPaint.setAlpha(alpha);
//    }
//
//    public void setEraserSize(float size) {
//        mEraserSize = size;
//        mPaint.setStrokeWidth(mEraserSize);
//    }
//
//    public void setPenRawSize(float size) {
//        mDrawSize = size;
//        mPaint.setStrokeWidth(mDrawSize);
//    }
//
//    public void setPenColor(int color) {
//        mPaint.setColor(color);
//    }
//    private void init() {
//        mPaint = new Paint(Paint.ANTI_ALIAS_FLAG | Paint.DITHER_FLAG);
//        mPaint.setStyle(Paint.Style.STROKE);
//        mPaint.setFilterBitmap(true);
//        mPaint.setStrokeJoin(Paint.Join.ROUND);
//        mPaint.setStrokeCap(Paint.Cap.ROUND);
//        mDrawSize = 10;
//        mEraserSize = 10;
//        mPaint.setStrokeWidth(mDrawSize);
//        mPaint.setARGB(255, 0, 0, 0);
//
//        mClearMode = new PorterDuffXfermode(PorterDuff.Mode.CLEAR);
//    }


}