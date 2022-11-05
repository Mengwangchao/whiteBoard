package com.example.writeboard;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Parcelable;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.example.writeboard.activity.BoardActivity;
import com.example.writeboard.utils.MqttClient;

public class MainActivity extends AppCompatActivity {

    private Button button;
    private Button button2;
    private Button button3;
    private TextView textView;
    private  MqttClient mqttClient;
    private Handler handler;

    @Override
    protected void onCreate(Bundle savedInstanceState)   {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        initView();

        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                 mqttClient=new MqttClient();
                mqttClient.connect(MainActivity.this);
                mqttClient.setQos(1);
            }
        });
        button2.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mqttClient.unsubscribe("a/b");
mqttClient.diconnect();

            }
        });
        button3.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mqttClient.subscribe("a/b");
//                Intent intent=new Intent();
//                intent.putExtra("a/b", (Parcelable) mqttClient);
//                intent.setClass(MainActivity.this, BoardActivity.class);

//                mqttClient.publish("a/b","{\n" +
//                        "  \"msg\": \"小浩\"\n" +
//                        "}",false);
                mqttClient.publish("a/b","{\n"+
                        "\"a\":\"1.000000\",\n" +
                        "\"b\":\"128.000000\",\n"+
                        "\"g\":\"0.000000\",\n"+
                        "\"r\":\"0.000000\"\n"+
                        "}",false);
            }
        });

    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    void initView() {
        button=findViewById(R.id.test_bt);
        button2=findViewById(R.id.test2_bt);
        button3=findViewById(R.id.button3);
        textView=findViewById(R.id.message);

    }

}