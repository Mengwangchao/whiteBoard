package com.example.writeboard.interfaces;

import org.eclipse.paho.client.mqttv3.MqttMessage;

public interface InMqttClientNotify {

    public void notifyDrawMessage(MqttMessage message);

    public void notifyAddPage(MqttMessage message);

    public void notifyChangeAuthority(MqttMessage message);

    public void notifyMovePage(MqttMessage message);

    public void notifyPaintSetting(MqttMessage message);

}
