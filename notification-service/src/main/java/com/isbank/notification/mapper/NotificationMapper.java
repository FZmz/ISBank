package com.isbank.notification.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.isbank.notification.entity.Notification;
import org.apache.ibatis.annotations.Mapper;

/**
 * 通知Mapper
 */
@Mapper
public interface NotificationMapper extends BaseMapper<Notification> {
}

