package com.isbank.notification.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import java.util.Map;

/**
 * 发送通知请求
 */
@Data
@ApiModel("发送通知请求")
public class SendNotificationRequest {
    @ApiModelProperty(value = "转账ID", required = true)
    private String transferId;
    
    @ApiModelProperty(value = "客户ID", required = true)
    private String customerId;
    
    @ApiModelProperty(value = "通知渠道", required = true, example = "SMS")
    private String channel;
    
    @ApiModelProperty(value = "模板代码", required = true, example = "TRANSFER_SUCCESS")
    private String templateCode;
    
    @ApiModelProperty("模板参数")
    private Map<String, Object> params;
}

