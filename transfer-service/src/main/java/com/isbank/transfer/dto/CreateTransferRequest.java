package com.isbank.transfer.dto;

import com.isbank.common.enums.TransferType;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import java.math.BigDecimal;

/**
 * 创建转账请求
 */
@Data
@ApiModel("创建转账请求")
public class CreateTransferRequest {
    @ApiModelProperty(value = "源账户ID", required = true)
    private Long fromAccountId;
    
    @ApiModelProperty(value = "目标账户ID", required = true)
    private Long toAccountId;
    
    @ApiModelProperty(value = "金额", required = true)
    private BigDecimal amount;
    
    @ApiModelProperty(value = "币种", required = true, example = "CNY")
    private String currency;
    
    @ApiModelProperty(value = "转账类型", required = true, example = "INTERNAL")
    private TransferType type;
}

