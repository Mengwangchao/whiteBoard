package com.example.writeboard.activity;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import com.example.writeboard.R;

public class LoginActivity extends AppCompatActivity implements View.OnClickListener
{
private Button crRoombt;
private Button inRoombt;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        initView();
        crRoombt.setOnClickListener(this);
        inRoombt.setOnClickListener(this);
    }

    private void initView() {
        crRoombt=findViewById(R.id.crRoom_bt);
        inRoombt=findViewById(R.id.inRoom_bt);
    }

    @Override
    public void onClick(View v) {
        Intent intent = new Intent();
        switch (v.getId()){
            case R.id.crRoom_bt:
                intent.setClass(this,BoardActivity.class);
                intent.putExtra("mode","1");
                startActivity(intent);
                break;
            case R.id.inRoom_bt:
                intent.putExtra("mode","2");
                intent.setClass(this,BoardActivity.class);
                startActivity(intent);
                break;
        }

    }
}