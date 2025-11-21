package com.isbank.account.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.isbank.common.enums.AccountStatus;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 账户实体
 */
@Data
@TableName("accounts")
public class Account {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private String customerId;
    
    private String accountNo;
    
    private String currency;
    
    private BigDecimal balance;
    
    private AccountStatus status;
    
    private LocalDateTime createdAt;
    
    private LocalDateTime updatedAt;
}

