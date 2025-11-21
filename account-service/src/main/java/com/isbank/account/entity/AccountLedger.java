package com.isbank.account.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.isbank.common.enums.Direction;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 账户分户账实体
 */
@Data
@TableName("account_ledger")
public class AccountLedger {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long accountId;
    
    private String transactionId;
    
    private Direction direction;
    
    private BigDecimal amount;
    
    private BigDecimal balanceAfter;
    
    private LocalDateTime occurredAt;
}

