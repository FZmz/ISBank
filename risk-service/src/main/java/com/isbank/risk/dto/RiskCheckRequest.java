package com.isbank.risk.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import java.math.BigDecimal;

/**
 * 风控检查请求
 */
@Data
@ApiModel("风控检查请求")
public class RiskCheckRequest {
    @ApiModelProperty(value = "客户ID")
    private String customerId;
    
    @ApiModelProperty(value = "源账户ID", required = true)
    private Long fromAccountId;
    
    @ApiModelProperty(value = "目标账户ID", required = true)
    private Long toAccountId;
    
    @ApiModelProperty(value = "金额", required = true)
    private BigDecimal amount;
    
    @ApiModelProperty(value = "币种", required = true)
    private String currency;
}

