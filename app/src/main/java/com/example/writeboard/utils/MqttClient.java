package com.example.writeboard.utils;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.util.JsonReader;
import android.util.Log;
import android.widget.Toast;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import org.eclipse.paho.android.service.MqttAndroidClient;
import org.eclipse.paho.client.mqttv3.IMqttActionListener;
import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
import org.eclipse.paho.client.mqttv3.IMqttToken;
import org.eclipse.paho.client.mqttv3.MqttCallback;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.json.JSONException;
import org.json.JSONObject;

public class MqttClient {
    private static String TAG = "AndroidMqttClient";
    private MqttAndroidClient mqttAndroidClient;
    private String userId;

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

//    private static String serverURI="ws://broker.emqx.io:8083/mqtt";
    private static String serverURI="ws://39.105.149.69:8083";

    private String username;
    private String password;
    private int qos = 2;
    private MqttMessage message;
    private MqttConnectOptions mqttConnectOptions;
    private Context mcontext;
    public void setQos(int gos) {
        this.qos = gos;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setMessage(MqttMessage message) {
        this.message = message;
    }

    public void connect(Context context) {

        this.mcontext = context;
        mqttAndroidClient = new MqttAndroidClient(mcontext, serverURI, userId);
        mqttAndroidClient.setCallback(new MqttCallback() {
            @Override
            public void connectionLost(Throwable cause) {
                Log.d(TAG, "connection lost" + cause.toString());
            }

            @Override
            public void messageArrived(String topic, MqttMessage message) throws Exception {
                Log.d(TAG, "收到的消息：" + message.toString() + "--from topic:" + topic);
                Log.i("AndroidMqttClient", "获得的消息是" + message.toString());
                String msg = new String(message.getPayload());
                JsonParser jp = new JsonParser();
                JsonObject jo = jp.parse(msg).getAsJsonObject();
                int mode=jo.get("mode").getAsInt();
                Float a = jo.get("a").getAsFloat();
                Float b = jo.get("b").getAsFloat();
                String c = jo.get("id").getAsString();
if(!userId.equals(c)){
                Toast.makeText(mcontext, "x坐标" + a + "\ny坐标" + b + "\n id:"+c +"\n mode:"+mode, Toast.LENGTH_SHORT).show();
                Intent intent = new Intent();
                intent.setAction("xiaohao");//要通知的广播XXXXX名称
                intent.putExtra("x",a);
                intent.putExtra("y",b);
                intent.putExtra("mode",mode);
                intent.putExtra("id",c+"");
                context.sendBroadcast(intent);}
            }

            @Override
            public void deliveryComplete(IMqttDeliveryToken token) {

            }
        });
        mqttConnectOptions = new MqttConnectOptions();
        mqttConnectOptions.setUserName("emqx_user");
        mqttConnectOptions.setPassword("emqx_password".toCharArray());
        try {
            mqttAndroidClient.connect(mqttConnectOptions, null, new IMqttActionListener() {
                @Override
                public void onSuccess(IMqttToken asyncActionToken) {
                    Toast.makeText(mcontext,"远程连接成功",Toast.LENGTH_SHORT).show();
                    Log.d(TAG, "连接成功");
                }
                @Override
                public void onFailure(IMqttToken asyncActionToken, Throwable exception) {
                    Toast.makeText(mcontext,"远程连接失败",Toast.LENGTH_SHORT).show();
                    Log.d(TAG, "连接失败" + exception);
                }
            });
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

    public void subscribe(String topic) {

        try {
            mqttAndroidClient.subscribe(topic, qos, mcontext, new IMqttActionListener() {
                @Override
                public void onSuccess(IMqttToken asyncActionToken) {
                    Log.d(TAG, "订阅：" + topic + "成功");
                }

                @Override
                public void onFailure(IMqttToken asyncActionToken, Throwable exception) {
                    Log.d(TAG, "订阅：" + topic + "失败");
                }
            });
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

    public void publish(String topic, String msg, boolean retained) {
        message = new MqttMessage();
        message.setPayload(msg.getBytes());
        message.setQos(qos);
        message.setRetained(retained);
        try {
            mqttAndroidClient.publish(topic, message, null, new IMqttActionListener() {
                @Override
                public void onSuccess(IMqttToken asyncActionToken) {
                    Log.d(TAG, "发送" + message + "to" + topic + "成功");
                }

                @Override
                public void onFailure(IMqttToken asyncActionToken, Throwable exception) {
                    Log.d(TAG, "发送" + message + "to" + topic + "失败");

                }
            });
        } catch (MqttException e) {
            e.printStackTrace();
        }

    }

    public void unsubscribe(String topic) {

        try {
            mqttAndroidClient.unsubscribe(topic, null, new IMqttActionListener() {
                @Override
                public void onSuccess(IMqttToken asyncActionToken) {
                    Log.d(TAG, "取消订阅" + topic + "成功");
                }

                @Override
                public void onFailure(IMqttToken asyncActionToken, Throwable exception) {
                    Log.d(TAG, "取消订阅" + topic + "失败");
                }
            });
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

    public void diconnect() {
        try {
            mqttAndroidClient.disconnect(null, new IMqttActionListener() {
                @Override
                public void onSuccess(IMqttToken asyncActionToken) {
                    Log.d(TAG, "取消链接");
                }

                @Override
                public void onFailure(IMqttToken asyncActionToken, Throwable exception) {
                    Log.d(TAG, "取消连接失败");

                }
            });
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

}
