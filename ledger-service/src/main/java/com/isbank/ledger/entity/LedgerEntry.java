package com.isbank.ledger.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 总账分录实体
 */
@Data
@TableName("ledger_entries")
public class LedgerEntry {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private String transactionId;
    
    private Long ledgerAccountId;
    
    private BigDecimal debitAmount;
    
    private BigDecimal creditAmount;
    
    private LocalDateTime occurredAt;
}

