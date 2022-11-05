package com.example.writeboard.activity;

import androidx.appcompat.app.AppCompatActivity;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import com.example.writeboard.R;
import com.example.writeboard.adapter.BoardAdapter;
import com.example.writeboard.been.User;
import com.example.writeboard.utils.MqttClient;
import com.example.writeboard.view.BoardViewPager;
import com.example.writeboard.view.PaletteView;
import com.example.writeboard.view.PopBottomWindow;

import java.util.ArrayList;

public class BoardActivity extends AppCompatActivity implements View.OnClickListener {
    private TextView textView;
    private Button redoBt;
    private Button ondoBt;
    private Button eraserBt;
    private Button clearBt;
    private Button saveBt;
    private Button sizeBt;
    private Button colorBt;
    private MqttClient mqttClient;
    private boolean mode = true;
    private BoardViewPager boardPage;
    private ArrayList<PaletteView> boardList;
    private BoardAdapter boardAdapter;
    private int currentItem = 0;
    private ImageView lastPageView;
    private ImageView nextPageView;
    private ImageView addPageView;
    private ImageView popBackView;
    private TextView currentTv;
    private TextView allItemTv;
    private View PopupView;
    private boolean IsPopView;
    private PopBottomWindow popupWindow;
    private SeekBar seekBar;
    private Button button;
    private User user;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_board);
        Intent intent = getIntent();
        String modeString = intent.getStringExtra("mode");
        user=intent.getParcelableExtra("User");
        PopupView = LayoutInflater.from(this).inflate(R.layout.popupview, null);

        initMqttClient();
        initView();
//
        boardList = new ArrayList<>();
        boardList.add(new PaletteView(this));
        boardList.get(boardList.size() - 1).setMqttClient(mqttClient);
//
        boardAdapter = new BoardAdapter(boardList);
        boardPage.setAdapter(boardAdapter);
        boardPage.setCurrentItem(currentItem);
        boardPage.setIsSwipe(false);


        initData();
        if (modeString.equals("2")) {
            showExitDiaglog();
        } else {
            textView.setText(modeString+user.getUserId()+user.getUserName()+user.getPassWord());
        }
        popupWindow = new PopBottomWindow.Builder()
                .setContentViewId(R.layout.popupview)
                .setFouse(false)
                .setOutSideCancle(true)
                .setContext(this)
                .setHeight(ViewGroup.LayoutParams.WRAP_CONTENT)
                .setWidth(ViewGroup.LayoutParams.MATCH_PARENT)
                .setAnimation(R.style.anim_menu_bottombar)
                .build();
        popBackView.setOnClickListener(v -> popupWindow.dismiss());

        seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (mode) {
                    boardList.get(boardPage.getCurrentItem()).setPenRawSize(progress);
                } else {
                    boardList.get(boardPage.getCurrentItem()).setEraserSize(progress);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
        redoBt.setOnClickListener(this);
        ondoBt.setOnClickListener(this);
        eraserBt.setOnClickListener(this);
        clearBt.setOnClickListener(this);
        saveBt.setOnClickListener(this);
        sizeBt.setOnClickListener(this);
        colorBt.setOnClickListener(this);
        lastPageView.setOnClickListener(this);
        nextPageView.setOnClickListener(this);
        addPageView.setOnClickListener(this);
        button.setOnClickListener(this);
    }

    private void initMqttClient() {
mqttClient=new MqttClient();
mqttClient.setUserId(user.getUserId());
mqttClient.connect(BoardActivity.this);
mqttClient.setQos(2);
mqttClient.setUsername(user.getUserName());
mqttClient.setPassword(user.getPassWord());

    }

    private void initData() {
        currentTv.setText(boardPage.getCurrentItem() + 1 + "");
        allItemTv.setText(boardList.size() + "");
    }

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
                    boardList.get(boardPage.getCurrentItem()).setMode(PaletteView.Mode.ERASER);
                    mode = false;
                    eraserBt.setText("draw");
                } else {
                    boardList.get(boardPage.getCurrentItem()).setMode(PaletteView.Mode.DRAW);
                    mode = true;
                    eraserBt.setText("eraser");
                }
                break;
            case R.id.clear_bt:
                boardList.get(boardPage.getCurrentItem()).clear();
                break;
            case R.id.save_bt:
                Toast.makeText(this, "图片已经保存", Toast.LENGTH_SHORT).show();
                break;
            case R.id.size_bt:

                if (!IsPopView) {
                    IsPopView = true;
                    popupWindow.showAtLocation(findViewById(R.id.layout_board), Gravity.BOTTOM, 0, 0);
                } else {
                    IsPopView = false;
                    popupWindow.dismiss();
                }
                break;
            case R.id.color_bt:
                boardList.get(boardPage.getCurrentItem()).setPenColor(Color.GREEN);
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
                boardList.add(new PaletteView(this));
                boardAdapter = new BoardAdapter(boardList);
                boardPage.setAdapter(boardAdapter);
                currentItem = boardList.size() - 1;
                boardPage.setCurrentItem(currentItem);
                currentTv.setText(boardList.size() + "");
                allItemTv.setText(boardPage.getCurrentItem() + 1 + "");
                Toast.makeText(this, "当前的页数：" + (boardPage.getCurrentItem() + 1), Toast.LENGTH_SHORT).show();
                break;
            case R.id.button:
                popupWindow.dismiss();
                break;
            default:
                break;
        }
    }

    private void initView() {
        textView = findViewById(R.id.moshi);
        redoBt = findViewById(R.id.redo_bt);
        ondoBt = findViewById(R.id.undo_bt);
        eraserBt = findViewById(R.id.eraser_bt);
        clearBt = findViewById(R.id.clear_bt);
        saveBt = findViewById(R.id.save_bt);
        sizeBt = findViewById(R.id.size_bt);
        colorBt = findViewById(R.id.color_bt);
        boardPage = findViewById(R.id.boardpage);
        lastPageView = findViewById(R.id.lastPage_bt);
        nextPageView = findViewById(R.id.nextPage_bt);
        currentTv = findViewById(R.id.currentItem_tv);
        allItemTv = findViewById(R.id.allItem_tv);
        addPageView = findViewById(R.id.addPage);
        popBackView = PopupView.findViewById(R.id.popback_bt);
        seekBar = PopupView.findViewById(R.id.seekBar);
        button = PopupView.findViewById(R.id.button);
    }

    private void showExitDiaglog() {
        final EditText editText = new EditText(this);
        editText.setMinLines(1);
        new AlertDialog.Builder(this)
                .setTitle("请输入房间号")
                .setIcon(android.R.drawable.sym_def_app_icon)
                .setView(editText)
                .setPositiveButton("true", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        textView.setText("已经加入房间");
                    }
                })
                .setNegativeButton("取消", null)
                .show();
    }
//    @Override
//    public boolean dispatchTouchEvent(MotionEvent event){
//        if(popupWindow!=null&&popupWindow.getmPopupWindow().isShowing()){
//            return false;
//        }
//        return super.dispatchTouchEvent(event);
//    }

}