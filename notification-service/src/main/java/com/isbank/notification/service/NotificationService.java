package com.isbank.notification.service;

import com.isbank.notification.dto.SendNotificationRequest;
import com.isbank.notification.entity.Notification;
import com.isbank.notification.mapper.NotificationMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * 通知服务
 */
@Slf4j
@Service
public class NotificationService {

    @Autowired
    private NotificationMapper notificationMapper;

    /**
     * 发送通知
     */
    @Transactional(rollbackFor = Exception.class)
    public Notification sendNotification(SendNotificationRequest request) {
        log.info("发送通知: transferId={}, customerId={}, channel={}", 
                request.getTransferId(), request.getCustomerId(), request.getChannel());
        
        Notification notification = new Notification();
        notification.setTransferId(request.getTransferId());
        notification.setCustomerId(request.getCustomerId());
        notification.setChannel(request.getChannel());
        notification.setTemplateCode(request.getTemplateCode());
        notification.setStatus("SENT"); // 模拟发送成功
        notification.setSentAt(LocalDateTime.now());
        notification.setCreatedAt(LocalDateTime.now());
        
        notificationMapper.insert(notification);
        
        log.info("通知发送成功: notificationId={}", notification.getId());
        return notification;
    }

    /**
     * 查询通知
     */
    public Notification getNotification(Long notificationId) {
        return notificationMapper.selectById(notificationId);
    }
}

