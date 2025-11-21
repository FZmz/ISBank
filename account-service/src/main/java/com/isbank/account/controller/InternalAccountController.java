package com.isbank.account.controller;

import com.isbank.account.dto.CreditRequest;
import com.isbank.account.dto.DebitRequest;
import com.isbank.account.service.AccountService;
import com.isbank.common.response.Result;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 内部账户控制器(供其他服务调用)
 */
@Api(tags = "内部账户接口")
@RestController
@RequestMapping("/internal/accounts")
public class InternalAccountController {

    @Autowired
    private AccountService accountService;

    @ApiOperation("扣款")
    @PostMapping("/debit")
    public Result<Void> debit(@RequestBody DebitRequest request) {
        accountService.debit(request);
        return Result.success();
    }

    @ApiOperation("入账")
    @PostMapping("/credit")
    public Result<Void> credit(@RequestBody CreditRequest request) {
        accountService.credit(request);
        return Result.success();
    }
}

