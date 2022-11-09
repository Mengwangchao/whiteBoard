package com.xxxx.whiteboard.mqttConn;

import com.xxxx.whiteboard.util.JsonTool;
import com.xxxx.whiteboard.validator.ValidatorUtil;
import lombok.extern.slf4j.Slf4j;
import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
import org.eclipse.paho.client.mqttv3.MqttCallback;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.json.JSONObject;

/**
 * 常规MQTT回调函数
 *
 * @author fan yang
 * @since 2020/1/9 16:26
 */
@Slf4j
public class MQTTCallback implements MqttCallback {

    /**
     * MQTT 断开连接会执行此方法
     */
    @Override
    public void connectionLost(Throwable throwable) {
        log.info("断开了MQTT连接 ：{}", throwable.getMessage());
        log.error(throwable.getMessage(), throwable);
    }

    /**
     * publish发布成功后会执行到这里
     */
    @Override
    public void deliveryComplete(IMqttDeliveryToken iMqttDeliveryToken) {
        log.info("发布消息成功");
    }

    /**
     * subscribe订阅后得到的消息会执行到这里
     */
    @Override
    public void messageArrived(String topic, MqttMessage message) {
        // 此处可以将订阅得到的消息进行业务处理、数据存储
        log.info("收到来自 " + topic + " 的消息：{}", new String(message.getPayload()));
        // 将接收到的数据转换成 json 数据
        JSONObject jsonObject;
        try {
            jsonObject = new JSONObject(new String(message.getPayload())); // 成功说明可以转换成json

            if (ValidatorUtil.isRoomId(topic)){
                // 这个是正在画点的时候
                JsonTool.touching(jsonObject);
            }
            // 判断主题
            switch (topic){
                case "touchStart":
                    JsonTool.touchStart(jsonObject); // 我认为这个touchStart对后端来说就是
                    break;
                case "touchEnd": // 手指结束滑动，实时同步所有短当前手指即将离开屏幕，可以释放和保存资源
                    JsonTool.touchEnd(jsonObject);
                    break;
                case "joinRoom":
                    JsonTool.joinRoom(jsonObject);
                    break;
                case "createRoom":
                    JsonTool.createRoom(jsonObject);
                    break;
                case "addPage":
                    JsonTool.addPage(jsonObject);
                    break;
                case "deletePage":
                    JsonTool.deletePage(jsonObject);
                    break;
                case "nextPage":
                    JsonTool.nextPage(jsonObject);
                    break;
                case "upPage":
                    JsonTool.upPage(jsonObject);
                    break;
                default:
                    JsonTool.touching(jsonObject);
                    break; // 12位数字的roomId: 手指正在滑动，实时同步所有端当前手指所在坐标
            }
        } catch (Exception e){
            // 说明发过来的数据是字符串类型，不是jsonObject类型
        }
    }
}
