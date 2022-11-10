package com.example.writeboard.activity;

import androidx.appcompat.app.AppCompatActivity;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.example.writeboard.R;
import com.example.writeboard.been.User;

import java.util.Random;

public class LoginActivity extends AppCompatActivity implements View.OnClickListener {
    private EditText userNameEt;
    private EditText passwordEt;
    private Button crRoombt;
    private Button inRoombt;
    private String userName;
    private String passWord;
    private String roomId;
    private Intent intent;
    private User user;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        intent = new Intent();
        initView();
        crRoombt.setOnClickListener(this);
        inRoombt.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        userName = userNameEt.getText().toString();
        passWord = passwordEt.getText().toString();
        user = new User(userName, passWord);
        switch (v.getId()) {
            case R.id.crRoom_bt:
                if (!userName.isEmpty() && !passWord.isEmpty()) {
                    Log.i("xiaohao", "" + userName.isEmpty());
                    createRoom();
                    intent.setClass(this, BoardActivity.class);
                    intent.putExtra("User", user);
                    intent.putExtra("mode", "1");
                    intent.putExtra("roomId", roomId);
                    startActivity(intent);
                } else {
                    Toast.makeText(this, "用户名,密码不能为空！", Toast.LENGTH_SHORT).show();
                }
                break;
            case R.id.inRoom_bt:
                if (!userName.isEmpty() && !passWord.isEmpty()) {
                    showExitDiaglog();


                } else {

                    Toast.makeText(this, "用户名,密码不能为空！", Toast.LENGTH_SHORT).show();
                }
                break;
        }

    }

    private void initView() {
        crRoombt = findViewById(R.id.crRoom_bt);
        inRoombt = findViewById(R.id.inRoom_bt);
        userNameEt = findViewById(R.id.username);
        passwordEt = findViewById(R.id.password);
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
                        Toast.makeText(LoginActivity.this, "加入了房间", Toast.LENGTH_SHORT).show();
                        roomId = editText.getText().toString();
                        intent.setClass(LoginActivity.this, BoardActivity.class);
                        intent.putExtra("User", user);
                        intent.putExtra("mode", "2");
                        intent.putExtra("roomId", roomId);
                        startActivity(intent);

                    }
                })
                .setNegativeButton("取消", null)
                .show();
    }

    private void createRoom() {
        Random random = new Random();

        for (int i = 0; i < 12; i++) {
            if (i == 0) {
                roomId = (random.nextInt(9) + 1)+"";
            } else {
                roomId += (random.nextInt(10));
            }
        }
    }

}