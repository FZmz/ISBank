package com.isbank.account.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import java.math.BigDecimal;

/**
 * 入账请求
 */
@Data
@ApiModel("入账请求")
public class CreditRequest {
    @ApiModelProperty(value = "账户ID", required = true)
    private Long accountId;
    
    @ApiModelProperty(value = "金额", required = true)
    private BigDecimal amount;
    
    @ApiModelProperty(value = "币种", required = true)
    private String currency;
    
    @ApiModelProperty(value = "交易ID", required = true)
    private String transactionId;
}

