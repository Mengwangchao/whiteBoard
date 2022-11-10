package com.example.writeboard.activity;

import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import com.example.writeboard.R;
import com.example.writeboard.adapter.BoardAdapter;
import com.example.writeboard.been.User;
import com.example.writeboard.utils.BoardPaint;
import com.example.writeboard.utils.MqttClient;
import com.example.writeboard.view.BoardViewPager;
import com.example.writeboard.view.PaletteView;
import com.example.writeboard.view.PopBottomWindow;
import com.example.writeboard.view.TestButton;

import java.util.ArrayList;
import java.util.Random;

public class BoardActivity extends AppCompatActivity implements View.OnClickListener {
    private static BoardPaint mBoardPaint = BoardPaint.getmBoardPaint();
    private TextView pensizeTv;
    private TextView roomIdTv;
    private ImageView redoBt;
    private ImageView ondoBt;
    private ImageView eraserBt;
    private ImageView clearBt;
    private ImageView saveBt;
    private ImageView colorBt;
    private ImageView sizeIv;
    private MqttClient mqttClient;
    private boolean mode = true;
    private BoardViewPager boardPage;
    private ArrayList<PaletteView> boardList;
    private BoardAdapter boardAdapter;
    private int currentItem = 0;
    private ImageView lastPageView;
    private ImageView nextPageView;
    private ImageView addPageView;
    private TextView currentTv;
    private TextView allItemTv;
    private User user;
    private SeekBar pensizeSk;
    private AlertDialog penSizeDialog;
    private AlertDialog penColorDialog;
    private View penSizeView;


    private View penColorView;
    private TextView color_a;
    private TextView color_r;
    private TextView color_g;
    private TextView color_b;
    private ImageView colorView;
    private SeekBar color_a_Sk;
    private SeekBar color_r_Sk;
    private SeekBar color_g_Sk;
    private SeekBar color_b_Sk;


    private View boardImageView;

    private String roomId = "";
    private String modeString;


    @RequiresApi(api = Build.VERSION_CODES.Q)
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_board);
        Intent intent = getIntent();
        modeString = intent.getStringExtra("mode");
        user = intent.getParcelableExtra("User");
        roomId = intent.getStringExtra("roomId");

        initMqttClient();
        initView();
        boardList = new ArrayList<>();
        PaletteView paletteView = new PaletteView(this);
        paletteView.setBoardPaint(mBoardPaint);
        paletteView.setRoomId(roomId);

        boardList.add(paletteView);
        boardList.get(boardList.size() - 1).setMqttClient(mqttClient);
        boardAdapter = new BoardAdapter(boardList);
        boardPage.setAdapter(boardAdapter);
        boardPage.setCurrentItem(currentItem);
        boardPage.setIsSwipe(false);
        paletteView.setCurrentPage(boardPage.getCurrentItem() + 1 + "");


        initData();


        redoBt.setOnClickListener(this);
        ondoBt.setOnClickListener(this);
        eraserBt.setOnClickListener(this);
        clearBt.setOnClickListener(this);
        saveBt.setOnClickListener(this);
        sizeIv.setOnClickListener(this);
        colorBt.setOnClickListener(this);
        lastPageView.setOnClickListener(this);
        nextPageView.setOnClickListener(this);
        addPageView.setOnClickListener(this);

    }

    /**
     * click listener
     *
     * @param v
     */
    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.redo_bt:
                boardList.get(boardPage.getCurrentItem()).redo();
                break;
            case R.id.undo_bt:
                boardList.get(boardPage.getCurrentItem()).undo();
                break;
            case R.id.eraser_bt:
                if (mode) {
                    mBoardPaint.setMode(BoardPaint.Mode.ERASER);
                    mode = false;
                    eraserBt.setImageDrawable(getDrawable(R.drawable.ic_baseline_crop_portrait_24));
                } else {
                    mBoardPaint.setMode(BoardPaint.Mode.DRAW);
                    mode = true;
                    eraserBt.setImageDrawable(getDrawable(R.drawable.ic_baseline_palette_24));
                }
                break;
            case R.id.clear_bt:
                boardList.get(boardPage.getCurrentItem()).clear();
                break;
            case R.id.save_bt:
                Toast.makeText(this, "图片已经保存", Toast.LENGTH_SHORT).show();
                break;
            case R.id.size_bt:
                penSizeDialog.show();
                break;
            case R.id.color_bt:
                Toast.makeText(this, "画笔颜色\n:" + mBoardPaint.getPenColor(), Toast.LENGTH_SHORT).show();
                mBoardPaint.setmFigure(BoardPaint.Figure.STRAIGHTLINE);
                penColorDialog.show();
                break;
            case R.id.lastPage_bt:
                if (0 < currentItem && currentItem < boardList.size()) {
                    --currentItem;
                    boardPage.setCurrentItem(currentItem);
                    currentTv.setText(currentItem + 1 + "");
                }
                break;
            case R.id.nextPage_bt:
                if (0 <= currentItem && currentItem < boardList.size() - 1) {
                    currentItem++;
                    boardPage.setCurrentItem(currentItem);
                    currentTv.setText(currentItem + 1 + "");
                }
                Toast.makeText(this, "当前页数:" + boardPage.getCurrentItem() + "\n当前总页数大小：" + boardList.size(), Toast.LENGTH_SHORT).show();
                break;
            case R.id.addPage:
                Toast.makeText(this, "添加了新的一页", Toast.LENGTH_SHORT).show();
                PaletteView paletteView = new PaletteView(this);
                paletteView.setBoardPaint(mBoardPaint);
                paletteView.setCurrentPage(boardPage.getCurrentItem() + 1 + "");
                paletteView.setRoomId(roomId);
                boardList.add(paletteView);
                boardList.get(boardList.size() - 1).setMqttClient(mqttClient);
                boardAdapter = new BoardAdapter(boardList);
                boardPage.setAdapter(boardAdapter);
                currentItem = boardList.size() - 1;

                boardPage.setCurrentItem(currentItem);
                currentTv.setText(boardList.size() + "");
                allItemTv.setText(boardPage.getCurrentItem() + 1 + "");
                Toast.makeText(this, "当前的页数：" + (boardPage.getCurrentItem() + 1), Toast.LENGTH_SHORT).show();
                break;
            default:
                break;
        }
    }

    /**
     * initMattClient
     */
    private void initMqttClient() {
//    实例化Mqtt对象
        mqttClient = new MqttClient();
//        规定的一个用户Id（user+12位随机数）
        mqttClient.setUserId(user.getUserId());
//        mqtt连接
        mqttClient.connect(BoardActivity.this);
//        设置QOS
        mqttClient.setQos(2);
//        加入用户名和密码
        mqttClient.setUsername(user.getUserName());
        mqttClient.setPassword(user.getPassWord());

    }

    /**
     * init Data
     */
    private void initData() {
        roomIdTv.setText("房间号：" + roomId);
        currentTv.setText(boardPage.getCurrentItem() + 1 + "");
        allItemTv.setText(boardList.size() + "");
        pensizeSk.setProgress(10);
        showSizeDiaglog();
        showColorDiaglog();
    }

    /**
     * init View
     */
    private void initView() {
        roomIdTv = findViewById(R.id.moshi);
        redoBt = findViewById(R.id.redo_bt);
        ondoBt = findViewById(R.id.undo_bt);
        eraserBt = findViewById(R.id.eraser_bt);
        clearBt = findViewById(R.id.clear_bt);
        saveBt = findViewById(R.id.save_bt);
        sizeIv = findViewById(R.id.size_bt);
        colorBt = findViewById(R.id.color_bt);
        boardPage = findViewById(R.id.boardpage);
        lastPageView = findViewById(R.id.lastPage_bt);
        nextPageView = findViewById(R.id.nextPage_bt);
        currentTv = findViewById(R.id.currentItem_tv);
        allItemTv = findViewById(R.id.allItem_tv);
        addPageView = findViewById(R.id.addPage);

        penSizeView = LayoutInflater.from(this).inflate(R.layout.pen_size, null);
        pensizeSk = penSizeView.findViewById(R.id.pensizesk);
        pensizeTv = penSizeView.findViewById(R.id.pensizetv);

        penColorView = LayoutInflater.from(this).inflate(R.layout.pen_color, null);
        color_a = penColorView.findViewById(R.id.color_a_tv);
        color_r = penColorView.findViewById(R.id.color_r_tv);
        color_g = penColorView.findViewById(R.id.color_g_tv);
        color_b = penColorView.findViewById(R.id.color_b_tv);
        color_a_Sk = penColorView.findViewById(R.id.color_a);
        color_r_Sk = penColorView.findViewById(R.id.color_r);
        color_g_Sk = penColorView.findViewById(R.id.color_g);
        color_b_Sk = penColorView.findViewById(R.id.color_b);
        colorView = penColorView.findViewById(R.id.imageView);


    }

    private void showSizeDiaglog() {


        pensizeTv.setText(String.valueOf(pensizeSk.getProgress()));
        pensizeSk.setMax(50);
        penSizeDialog = new AlertDialog.Builder(this)
                .setTitle("设置画笔大小")
                .setIcon(android.R.drawable.sym_def_app_icon)
                .setView(penSizeView)
                .setPositiveButton("commit", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        penSizeDialog.dismiss();
                    }
                })
                .create();

        pensizeSk.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                pensizeTv.setText(String.valueOf(pensizeSk.getProgress()));
                mBoardPaint.setPenRawSize(progress);
                Toast.makeText(BoardActivity.this, "移动了SeekBar" + mBoardPaint.getPenRawSize(), Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
    }

    private void showColorDiaglog() {

        penColorDialog = new AlertDialog.Builder(this)
                .setTitle("设置画笔颜色")
                .setIcon(android.R.drawable.sym_def_app_icon)
                .setView(penColorView)
                .setPositiveButton("commit", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        penSizeDialog.dismiss();
                    }
                })
                .create();
        color_a_Sk.setProgress(255);
        color_r_Sk.setProgress(0);
        color_g_Sk.setProgress(0);
        color_b_Sk.setProgress(0);
        color_a.setText(color_a_Sk.getProgress() + "");
        color_r.setText(color_r_Sk.getProgress() + "");
        color_g.setText(color_g_Sk.getProgress() + "");
        color_b.setText(color_b_Sk.getProgress() + "");

        color_a_Sk.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                color_a.setText(progress + "");
                int r = Integer.parseInt(color_r.getText().toString());
                int g = Integer.parseInt(color_g.getText().toString());
                int b = Integer.parseInt(color_b.getText().toString());

                colorView.setBackgroundColor(Color.argb(progress, r, g, b));
                mBoardPaint.setARGB(progress, r, g, b);

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
        color_r_Sk.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                color_r.setText(progress + "");
                int a = Integer.parseInt(color_a.getText().toString());
                int g = Integer.parseInt(color_g.getText().toString());
                int b = Integer.parseInt(color_b.getText().toString());

                colorView.setBackgroundColor(Color.argb(a, progress, g, b));
                mBoardPaint.setPenColor(a, progress, g, b);

            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
        color_g_Sk.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                color_g.setText(progress + "");
                int r = Integer.parseInt(color_r.getText().toString());
                int a = Integer.parseInt(color_g.getText().toString());
                int b = Integer.parseInt(color_b.getText().toString());

                colorView.setBackgroundColor(Color.argb(a, r, progress, b));
                mBoardPaint.setPenColor(a, r, progress, b);


            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
        color_b_Sk.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                color_b.setText(progress + "");
                int r = Integer.parseInt(color_r.getText().toString());
                int g = Integer.parseInt(color_g.getText().toString());
                int a = Integer.parseInt(color_b.getText().toString());

                colorView.setBackgroundColor(Color.argb(a, r, g, progress));
                mBoardPaint.setPenColor(a, r, g, progress);


            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });

    }

    @Override
    protected void onPause() {
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mqttClient.diconnect();
    }
}