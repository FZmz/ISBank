package com.isbank.risk.controller;

import com.isbank.common.response.Result;
import com.isbank.risk.dto.RiskCheckRequest;
import com.isbank.risk.dto.RiskCheckResponse;
import com.isbank.risk.service.RiskService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 风控控制器
 */
@Api(tags = "风控管理")
@RestController
@RequestMapping("/risk")
public class RiskController {

    @Autowired
    private RiskService riskService;

    @ApiOperation("风控检查")
    @PostMapping("/check")
    public Result<RiskCheckResponse> checkRisk(@RequestBody RiskCheckRequest request,
                                                @RequestParam(required = false) String transferId) {
        RiskCheckResponse response = riskService.checkRisk(request, transferId);
        return Result.success(response);
    }
}

