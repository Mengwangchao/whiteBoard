package com.example.writeboard.activity;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.example.writeboard.R;
import com.example.writeboard.been.BoardRoom;
import com.example.writeboard.been.User;

public class LoginActivity extends AppCompatActivity implements View.OnClickListener {
    private EditText userNameEt;
    private EditText passwordEt;
    private Button crRoombt;
    private Button inRoombt;
    private String userName;
    private String passWord;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        initView();
        crRoombt.setOnClickListener(this);
        inRoombt.setOnClickListener(this);
    }

    private void initView() {
        crRoombt = findViewById(R.id.crRoom_bt);
        inRoombt = findViewById(R.id.inRoom_bt);
        userNameEt = findViewById(R.id.username);
        passwordEt = findViewById(R.id.password);
    }

    @Override
    public void onClick(View v) {
        Intent intent = new Intent();
        userName = userNameEt.getText().toString();
        passWord = passwordEt.getText().toString();
        User user = new User(userName, passWord);
        switch (v.getId()) {
            case R.id.crRoom_bt:
                if (!userName.isEmpty() && !passWord.isEmpty()) {
                    Log.i("xiaohao",""+userName.isEmpty());
                    intent.setClass(this, BoardActivity.class);
                    intent.putExtra("User", user);
                    intent.putExtra("mode", "1");
                    startActivity(intent);
                } else {
                    Toast.makeText(this, "用户名\n密码不能为空！", Toast.LENGTH_SHORT).show();
                }
                break;
            case R.id.inRoom_bt:
                if (!userName.isEmpty() && !passWord.isEmpty()) {
                    intent.setClass(this, BoardActivity.class);
                    intent.putExtra("User", user);
                    intent.putExtra("mode", "2");
                    startActivity(intent);
                } else {
                    Toast.makeText(this, "用户名\n密码不能为空！", Toast.LENGTH_SHORT).show();
                }
                break;
        }

    }
}