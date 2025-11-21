package com.isbank.ledger.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

/**
 * 总账科目实体
 */
@Data
@TableName("ledger_accounts")
public class LedgerAccount {
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private String code;
    
    private String name;
    
    private String type; // ASSET/LIABILITY/INCOME/EXPENSE
}

