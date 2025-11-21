package com.isbank.risk.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

/**
 * 风控检查响应
 */
@Data
@ApiModel("风控检查响应")
public class RiskCheckResponse {
    @ApiModelProperty("检查结果:ALLOW/DENY")
    private String result;
    
    @ApiModelProperty("原因代码")
    private String reasonCode;
    
    public static RiskCheckResponse allow() {
        RiskCheckResponse response = new RiskCheckResponse();
        response.setResult("ALLOW");
        response.setReasonCode("OK");
        return response;
    }
    
    public static RiskCheckResponse deny(String reasonCode) {
        RiskCheckResponse response = new RiskCheckResponse();
        response.setResult("DENY");
        response.setReasonCode(reasonCode);
        return response;
    }
}

