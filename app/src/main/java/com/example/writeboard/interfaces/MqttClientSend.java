package com.example.writeboard.interfaces;

public interface MqttClientSend {
    public void touchStart(float x,float y);

    public void touchMove(float x,float y,String roomId);

    public void touchEnd(float x,float y);


}
