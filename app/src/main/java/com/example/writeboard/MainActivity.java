package com.example.writeboard;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.animation.BounceInterpolator;
import android.view.animation.LinearInterpolator;
import android.widget.Button;
import android.widget.ImageView;

import com.example.writeboard.utils.DrawUtils;

import java.util.Arrays;
import java.util.List;

public class MainActivity extends AppCompatActivity {
    ImageView color_bt;
    List<ImageView> colorList;
    ImageView mFirst_bt, mSecond_bt, mThird_bt, mForth_bt;
    private boolean colorAnimationIsFinshed = true;
    private boolean colorIsOpen = false;
    private float space;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        initView();

        colorList = Arrays.asList(new ImageView[]{mFirst_bt, mSecond_bt, mThird_bt, mForth_bt});
        color_bt.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.i("hao", "点击画板");

                if (colorAnimationIsFinshed) {
                    if (colorIsOpen) {
                        space = DrawUtils.dptopx(getApplication(), 70);
                    } else {
                        space = -DrawUtils.dptopx(getApplication(), 70);
                    }
                }
                for (ImageView image : colorList) {
                    int index = colorList.indexOf(image);
                    image.animate().translationYBy((index + 1) * space).setDuration(800).setInterpolator(new LinearInterpolator()).start();
                    image.setVisibility(View.VISIBLE);
                    Log.i("hao", image.getId() + "===" + index + "====" + (index + 1) * space);
                }
                colorIsOpen = !colorIsOpen;

            }

        });
    }

    void initView() {
        color_bt = findViewById(R.id.color_bt);
        mFirst_bt = findViewById(R.id.first_color);
        mSecond_bt = findViewById(R.id.second_color);
        mThird_bt = findViewById(R.id.third_color);
        mForth_bt = findViewById(R.id.forth_color);


    }

}