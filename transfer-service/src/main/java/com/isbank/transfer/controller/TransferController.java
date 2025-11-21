package com.isbank.transfer.controller;

import com.isbank.common.response.Result;
import com.isbank.transfer.dto.CreateTransferRequest;
import com.isbank.transfer.entity.Transfer;
import com.isbank.transfer.service.TransferService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 转账控制器
 */
@Api(tags = "转账管理")
@RestController
@RequestMapping("/transfers")
public class TransferController {

    @Autowired
    private TransferService transferService;

    @ApiOperation("发起转账")
    @PostMapping
    public Result<Transfer> createTransfer(@RequestBody CreateTransferRequest request) {
        Transfer transfer = transferService.createTransfer(request);
        return Result.success(transfer);
    }

    @ApiOperation("查询转账")
    @GetMapping("/{transferId}")
    public Result<Transfer> getTransfer(@PathVariable Long transferId) {
        Transfer transfer = transferService.getTransfer(transferId);
        return Result.success(transfer);
    }
}

