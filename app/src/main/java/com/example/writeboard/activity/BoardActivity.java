package com.example.writeboard.activity;

import androidx.appcompat.app.AppCompatActivity;

import android.app.AlertDialog;
import android.app.DatePickerDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.example.writeboard.R;
import com.example.writeboard.view.PaletteView;

public class BoardActivity extends AppCompatActivity implements View.OnClickListener {
    private TextView textView;
    private PaletteView paletteView;
    private Button redoBt;
    private Button ondoBt;
    private Button eraserBt;
    private Button clearBt;
    private Button saveBt;
    private Button sizeBt;
    private Button colorBt;
    private boolean mode=true;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_board);
        Intent intent = getIntent();
        String mode = intent.getStringExtra("mode");
        initView();

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
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.redo_bt:
                paletteView.redo();
                break;
            case R.id.undo_bt:
                paletteView.undo();
                break;
            case R.id.eraser_bt:
                if(mode) {
                    paletteView.setMode(PaletteView.Mode.ERASER);
                    mode=false;
                    eraserBt.setText("draw");
                }else{
                    paletteView.setMode(PaletteView.Mode.DRAW);
                    mode=true;
                    eraserBt.setText("eraser");
                }
                break;
            case R.id.clear_bt:
                paletteView.clear();
                break;
            case R.id.save_bt:
                Toast.makeText(this,"图片已经保存",Toast.LENGTH_SHORT).show();
                break;
            case R.id.size_bt:
                if(mode){
                    paletteView.setPenRawSize(40);
                }else{
                    paletteView.setEraserSize(40);
                }
                break;
            case R.id.color_bt:
                paletteView.setPenColor(Color.GREEN);
                break;


        }

    }

    private void initView() {
        textView = findViewById(R.id.moshi);
        paletteView = findViewById(R.id.paletteView);
        redoBt = findViewById(R.id.redo_bt);
        ondoBt = findViewById(R.id.undo_bt);
        eraserBt = findViewById(R.id.eraser_bt);
        clearBt = findViewById(R.id.clear_bt);
        saveBt = findViewById(R.id.save_bt);
        sizeBt = findViewById(R.id.size_bt);
        colorBt = findViewById(R.id.color_bt);
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

}