package com.example.writeboard.view;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Build;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.PopupWindow;

import androidx.annotation.LayoutRes;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

public class PopBottomWindow {

    private PopupWindow mPopupWindow;

    private View mContentView;

    private Context mContext;

    @RequiresApi(api = Build.VERSION_CODES.Q)
    public PopBottomWindow(Builder builder) {
        mContext = builder.getContext();
        // 创建view
        mContentView = LayoutInflater.from(mContext).inflate(builder.getContentViewId(), null);
        // 创建popupWindow
        mPopupWindow = new PopupWindow(mContentView, builder.getWidth(), builder.getHeight(), builder.isFouse());
        mPopupWindow.setOutsideTouchable(builder.isOutSideCancle());
        mPopupWindow.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        mPopupWindow.setFocusable(builder.fouse);
        mPopupWindow.setAnimationStyle(builder.getAnimation());
    }


    /**
     * 消失
     */
    public void dismiss() {
        if (mPopupWindow != null || mPopupWindow.isShowing()) {
            mPopupWindow.dismiss();
        }
    }


    /**
     * 获取控件
     *
     * @param itemId
     * @return
     */
    public View getItemView(@NonNull int itemId) {
        if (mPopupWindow != null && mContentView != null) {
            return mContentView.findViewById(itemId);
        }
        return null;
    }

    /**
     * 在父布局特定位置显示
     *
     * @param rootViewId
     * @param gravity
     * @param x
     * @param y
     * @return
     */
    public PopBottomWindow showAtLocation( int rootViewId, int gravity, int x, int y) {
        if (mPopupWindow != null) {
            View rootView = LayoutInflater.from(mContext).inflate(rootViewId, null);
            mPopupWindow.showAtLocation(rootView, gravity, x, y);
        }
        return this;
    }

    public PopBottomWindow showAsLocation(int targetViewId, int gravity, int offx, int offy) {
        if (mPopupWindow != null) {
            View targetview = LayoutInflater.from(mContext).inflate(targetViewId, null);
            mPopupWindow.showAsDropDown(targetview, offx, offy, gravity);
        }
        return this;
    }

    public PopBottomWindow showAsLocation(View targetView, int gravity, int offx, int offy) {
        if (mPopupWindow != null) {
            mPopupWindow.showAsDropDown(targetView, offx, offy, gravity);
        }
        return this;
    }

    /**
     * 根据id设置焦点监听
     *
     * @param viewid
     * @param listener
     */
    public void setOnFocusListener(int viewid, View.OnFocusChangeListener listener) {
        View view = getItemView(viewid);
        view.setOnFocusChangeListener(listener);
    }

    /**
     * 在父布局特定位置显示
     *
     * @param gravity
     * @param x
     * @param y
     * @return
     */
    public PopBottomWindow showAtLocation(View rootView, int gravity, int x, int y) {
        if (mPopupWindow != null) {
            mPopupWindow.showAtLocation(rootView, gravity, x, y);
        }
        return this;
    }


    public static class Builder {

        private Context context;

        private int contentViewId;

        private int width;

        private int height;

        private boolean fouse;

        private boolean outSideCancle;

        private int animation;

        public Context getContext() {
            return context;
        }

        public Builder setContext(Context context) {
            this.context = context;
            return this;
        }

        public int getContentViewId() {
            return contentViewId;
        }

        public Builder setContentViewId(int contentViewId) {
            this.contentViewId = contentViewId;
            return this;
        }

        public int getWidth() {
            return width;
        }

        public Builder setWidth(int width) {
            this.width = width;
            return this;
        }

        public int getHeight() {
            return height;
        }

        public Builder setHeight(int height) {
            this.height = height;
            return this;
        }

        public boolean isFouse() {
            return fouse;
        }

        public Builder setFouse(boolean fouse) {
            this.fouse = fouse;
            return this;
        }

        public boolean isOutSideCancle() {
            return outSideCancle;
        }

        public Builder setOutSideCancle(boolean outSideCancle) {
            this.outSideCancle = outSideCancle;
            return this;
        }

        public int getAnimation() {
            return animation;
        }

        public Builder setAnimation(int animation) {
            this.animation = animation;
            return this;
        }

        /**
         * 构建
         *
         * @return
         */
        @RequiresApi(api = Build.VERSION_CODES.Q)
        public PopBottomWindow build() {
            return new PopBottomWindow(this);
        }
    }

    public PopupWindow getmPopupWindow() {
        return mPopupWindow;
    }
}
