package com.isbank.ledger.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import java.util.List;

/**
 * 记账请求
 */
@Data
@ApiModel("记账请求")
public class PostEntriesRequest {
    @ApiModelProperty(value = "交易ID", required = true)
    private String transactionId;
    
    @ApiModelProperty(value = "分录列表", required = true)
    private List<EntryItem> entries;
    
    @Data
    @ApiModel("分录项")
    public static class EntryItem {
        @ApiModelProperty("总账科目代码")
        private String ledgerAccountCode;
        
        @ApiModelProperty("借方金额")
        private java.math.BigDecimal debitAmount;
        
        @ApiModelProperty("贷方金额")
        private java.math.BigDecimal creditAmount;
    }
}

