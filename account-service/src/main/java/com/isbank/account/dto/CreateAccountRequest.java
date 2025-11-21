package com.isbank.account.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

/**
 * 创建账户请求
 */
@Data
@ApiModel("创建账户请求")
public class CreateAccountRequest {
    @ApiModelProperty(value = "客户ID", required = true)
    private String customerId;
    
    @ApiModelProperty(value = "币种", required = true, example = "CNY")
    private String currency;
}

