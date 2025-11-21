package com.isbank.notification.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 通知实体
 */
@Data
@TableName("notifications")
public class Notification {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private String transferId;
    
    private String customerId;
    
    private String channel; // SMS/EMAIL/PUSH
    
    private String templateCode;
    
    private String status; // PENDING/SENT/FAILED
    
    private LocalDateTime sentAt;
    
    private LocalDateTime createdAt;
}

