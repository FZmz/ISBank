package com.isbank.notification.controller;

import com.isbank.common.response.Result;
import com.isbank.notification.dto.SendNotificationRequest;
import com.isbank.notification.entity.Notification;
import com.isbank.notification.service.NotificationService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 通知控制器
 */
@Api(tags = "通知管理")
@RestController
@RequestMapping("/notify")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    @ApiOperation("发送通知")
    @PostMapping
    public Result<Notification> sendNotification(@RequestBody SendNotificationRequest request) {
        Notification notification = notificationService.sendNotification(request);
        return Result.success(notification);
    }

    @ApiOperation("查询通知")
    @GetMapping("/{notificationId}")
    public Result<Notification> getNotification(@PathVariable Long notificationId) {
        Notification notification = notificationService.getNotification(notificationId);
        return Result.success(notification);
    }
}

