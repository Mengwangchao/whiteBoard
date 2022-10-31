package com.example.writeboard.activity;

import androidx.appcompat.app.AppCompatActivity;

import android.app.AlertDialog;
import android.app.DatePickerDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.media.Image;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.example.writeboard.MainActivity;
import com.example.writeboard.R;
import com.example.writeboard.adapter.BoardAdapter;
import com.example.writeboard.view.BoardViewPager;
import com.example.writeboard.view.PaletteView;

import java.util.ArrayList;
import java.util.List;

public class BoardActivity extends AppCompatActivity implements View.OnClickListener {
    private TextView textView;
    private Button redoBt;
    private Button ondoBt;
    private Button eraserBt;
    private Button clearBt;
    private Button saveBt;
    private Button sizeBt;
    private Button colorBt;
    private boolean mode = true;
    private BoardViewPager boardPage;
    private ArrayList<PaletteView> boardList;
    private BoardAdapter boardAdapter;
    private int currentItem = 0;
    private ImageView lastPageView;
    private ImageView nextPageView;
    private TextView currentTv;
    private TextView allItemTv;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_board);
        Intent intent = getIntent();
        String mode = intent.getStringExtra("mode");
        initView();

        boardList = new ArrayList<>();
        for (int i = 0; i < 4; i++) {
            boardList.add(new PaletteView(this));
        }
        boardAdapter = new BoardAdapter(boardList);
        boardPage.setAdapter(boardAdapter);
        boardPage.setCurrentItem(currentItem);
        boardPage.setIsSwipe(false);
        initData();

        if (mode.equals("2")) {
            showExitDiaglog();
        } else {
            textView.setText(mode);
        }
        redoBt.setOnClickListener(this);
        ondoBt.setOnClickListener(this);
        eraserBt.setOnClickListener(this);
        clearBt.setOnClickListener(this);
        saveBt.setOnClickListener(this);
        sizeBt.setOnClickListener(this);
        colorBt.setOnClickListener(this);
        lastPageView.setOnClickListener(this);
        nextPageView.setOnClickListener(this);
    }

    private void initData() {
        currentTv.setText(boardPage.getCurrentItem() + 1+"");
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
                if (mode) {
                    boardList.get(boardPage.getCurrentItem()).setPenRawSize(40);
                } else {
                    boardList.get(boardPage.getCurrentItem()).setEraserSize(40);
                }
                break;
            case R.id.color_bt:
                boardList.get(boardPage.getCurrentItem()).setPenColor(Color.GREEN);
                break;
            case R.id.lastPage_bt:
                if (0 < currentItem && currentItem < boardList.size()) {
                    boardPage.setCurrentItem(--currentItem);
                    currentTv.setText(currentItem+1+"");
                }
                break;
            case R.id.nextPage_bt:
                if (0 <= currentItem && currentItem < boardList.size()-1) {
                    boardPage.setCurrentItem(++currentItem);
                    currentTv.setText(currentItem+1+"");
                }
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
    /**
     * 页面监听事件
     */

}