package com.isbank.account.controller;

import com.isbank.account.dto.CreateAccountRequest;
import com.isbank.account.entity.Account;
import com.isbank.account.entity.AccountLedger;
import com.isbank.account.service.AccountService;
import com.isbank.common.response.Result;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 账户控制器
 */
@Api(tags = "账户管理")
@RestController
@RequestMapping("/accounts")
public class AccountController {

    @Autowired
    private AccountService accountService;

    @ApiOperation("创建账户")
    @PostMapping
    public Result<Account> createAccount(@RequestBody CreateAccountRequest request) {
        Account account = accountService.createAccount(request);
        return Result.success(account);
    }

    @ApiOperation("查询所有账户")
    @GetMapping
    public Result<List<Account>> getAllAccounts() {
        List<Account> accounts = accountService.getAllAccounts();
        return Result.success(accounts);
    }

    @ApiOperation("查询账户")
    @GetMapping("/{accountId}")
    public Result<Account> getAccount(@PathVariable Long accountId) {
        Account account = accountService.getAccount(accountId);
        return Result.success(account);
    }

    @ApiOperation("查询账户分户账")
    @GetMapping("/{accountId}/ledger")
    public Result<List<AccountLedger>> getAccountLedger(@PathVariable Long accountId) {
        List<AccountLedger> ledgers = accountService.getAccountLedger(accountId);
        return Result.success(ledgers);
    }

    @ApiOperation("冻结账户")
    @PostMapping("/{accountId}/freeze")
    public Result<Void> freezeAccount(@PathVariable Long accountId) {
        accountService.freezeAccount(accountId);
        return Result.success();
    }

    @ApiOperation("解冻账户")
    @PostMapping("/{accountId}/unfreeze")
    public Result<Void> unfreezeAccount(@PathVariable Long accountId) {
        accountService.unfreezeAccount(accountId);
        return Result.success();
    }
}

