package com.example.writeboard.utils;

import android.content.Context;
import android.os.Handler;
import android.util.Log;
import org.eclipse.paho.android.service.MqttAndroidClient;
import org.eclipse.paho.client.mqttv3.IMqttActionListener;
import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
import org.eclipse.paho.client.mqttv3.IMqttToken;
import org.eclipse.paho.client.mqttv3.MqttCallback;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;
public class MqttClient {

    private static MqttAndroidClient mqttAndroidClient;
    private static String TAG = "AndroidMqttClient";
    private String serverURI;
    private String username;
    private String password;
    private MqttMessage message;
    private int gos = 0;
    private MqttConnectOptions mqttConnectOptions;
    private Context mcontext;

    public void connect(Context context) {

        this.mcontext = context;
        serverURI = "ws://broker.emqx.io:8083/mqtt";
        username = "xiao";
        password = "xiao";
        mqttAndroidClient = new MqttAndroidClient(mcontext, serverURI, "java_client3");
        mqttAndroidClient.setCallback(new MqttCallback() {
            @Override
            public void connectionLost(Throwable cause) {
                Log.d(TAG, "connection lost" + cause.toString());
            }

            @Override
            public void messageArrived(String topic, MqttMessage message) throws Exception {
                Log.d(TAG, "收到的消息：" + message.toString() + "--from topic:" + topic);
                Log.i("AndroidMqttClient", "获得的消息是" + message.toString());
            }

            @Override
            public void deliveryComplete(IMqttDeliveryToken token) {

            }
        });
        mqttConnectOptions = new MqttConnectOptions();
        mqttConnectOptions.setUserName(username);
        mqttConnectOptions.setPassword(password.toCharArray());
        try {
            mqttAndroidClient.connect(mqttConnectOptions, null, new IMqttActionListener() {
                @Override
                public void onSuccess(IMqttToken asyncActionToken) {
                    Log.d(TAG, "连接成功");
                }

                @Override
                public void onFailure(IMqttToken asyncActionToken, Throwable exception) {
                    Log.d(TAG, "连接失败" + exception);
                }
            });
        } catch (MqttException e) {
            e.printStackTrace();
        }

    }

    public void setGos(int gos) {
        this.gos = gos;
    }

    public void subscribe(String topic) {

        try {
            mqttAndroidClient.subscribe(topic, gos, mcontext, new IMqttActionListener() {
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
        message.setQos(gos);
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
