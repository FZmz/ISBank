package com.isbank.ledger.controller;

import com.isbank.common.response.Result;
import com.isbank.ledger.dto.PostEntriesRequest;
import com.isbank.ledger.entity.LedgerEntry;
import com.isbank.ledger.service.LedgerService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 总账控制器
 */
@Api(tags = "总账管理")
@RestController
@RequestMapping("/entries")
public class LedgerController {

    @Autowired
    private LedgerService ledgerService;

    @ApiOperation("记账")
    @PostMapping
    public Result<Void> postEntries(@RequestBody PostEntriesRequest request) {
        ledgerService.postEntries(request);
        return Result.success();
    }

    @ApiOperation("查询交易分录")
    @GetMapping("/{transactionId}")
    public Result<List<LedgerEntry>> getEntries(@PathVariable String transactionId) {
        List<LedgerEntry> entries = ledgerService.getEntriesByTransactionId(transactionId);
        return Result.success(entries);
    }
}

