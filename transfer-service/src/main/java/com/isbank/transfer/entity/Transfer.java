package com.isbank.transfer.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.isbank.common.enums.TransferStatus;
import com.isbank.common.enums.TransferType;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 转账实体
 */
@Data
@TableName("transfers")
public class Transfer {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long fromAccountId;
    
    private Long toAccountId;
    
    private BigDecimal amount;
    
    private String currency;
    
    private TransferType type;
    
    private TransferStatus status;
    
    private LocalDateTime createdAt;
    
    private LocalDateTime lastUpdatedAt;
}

