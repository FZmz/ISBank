package com.isbank.risk.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 风控决策实体
 */
@Data
@TableName("risk_decisions")
public class RiskDecision {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private String transferId;
    
    private String result; // ALLOW/DENY
    
    private String reasonCode;
    
    private LocalDateTime createdAt;
}

