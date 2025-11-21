package com.isbank.transfer.service;

import com.isbank.common.enums.TransferStatus;
import com.isbank.common.exception.BusinessException;
import com.isbank.common.response.Result;
import com.isbank.transfer.dto.CreateTransferRequest;
import com.isbank.transfer.entity.Transfer;
import com.isbank.transfer.mapper.TransferMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 转账服务 - 核心编排逻辑
 */
@Slf4j
@Service
public class TransferService {

    @Autowired
    private TransferMapper transferMapper;

    @Autowired
    private RestTemplate restTemplate;

    @Value("${service.account}")
    private String accountServiceUrl;

    @Value("${service.risk}")
    private String riskServiceUrl;

    @Value("${service.ledger}")
    private String ledgerServiceUrl;

    @Value("${service.notification}")
    private String notificationServiceUrl;

    /**
     * 创建转账
     */
    @Transactional(rollbackFor = Exception.class)
    public Transfer createTransfer(CreateTransferRequest request) {
        log.info("开始创建转账: from={}, to={}, amount={}", 
                request.getFromAccountId(), request.getToAccountId(), request.getAmount());
        
        // 1. 创建转账记录
        Transfer transfer = new Transfer();
        transfer.setFromAccountId(request.getFromAccountId());
        transfer.setToAccountId(request.getToAccountId());
        transfer.setAmount(request.getAmount());
        transfer.setCurrency(request.getCurrency());
        transfer.setType(request.getType());
        transfer.setStatus(TransferStatus.INIT);
        transfer.setCreatedAt(LocalDateTime.now());
        transfer.setLastUpdatedAt(LocalDateTime.now());
        transferMapper.insert(transfer);
        
        String transferId = String.valueOf(transfer.getId());
        log.info("转账记录创建成功: transferId={}", transferId);
        
        try {
            // 2. 风控检查
            updateStatus(transfer, TransferStatus.RISK_CHECKING);
            checkRisk(request, transferId);
            updateStatus(transfer, TransferStatus.RISK_PASSED);
            
            // 3. 扣款
            debitAccount(request, transferId);
            updateStatus(transfer, TransferStatus.DEBIT_DONE);
            
            // 4. 入账
            creditAccount(request, transferId);
            updateStatus(transfer, TransferStatus.CREDIT_DONE);
            
            // 5. 总账记账
            postLedger(request, transferId);
            updateStatus(transfer, TransferStatus.LEDGER_POSTED);
            
            // 6. 发送通知
            sendNotification(request, transferId);
            updateStatus(transfer, TransferStatus.SUCCESS);
            
            log.info("转账成功: transferId={}", transferId);
            
        } catch (Exception e) {
            log.error("转账失败: transferId={}, error={}", transferId, e.getMessage(), e);
            updateStatus(transfer, TransferStatus.FAILED);
            throw new BusinessException("转账失败: " + e.getMessage());
        }
        
        return transfer;
    }

    /**
     * 查询转账
     */
    public Transfer getTransfer(Long transferId) {
        Transfer transfer = transferMapper.selectById(transferId);
        if (transfer == null) {
            throw new BusinessException("转账记录不存在");
        }
        return transfer;
    }

    /**
     * 风控检查
     */
    private void checkRisk(CreateTransferRequest request, String transferId) {
        log.info("调用风控服务: transferId={}", transferId);
        
        Map<String, Object> riskRequest = new HashMap<>();
        riskRequest.put("fromAccountId", request.getFromAccountId());
        riskRequest.put("toAccountId", request.getToAccountId());
        riskRequest.put("amount", request.getAmount());
        riskRequest.put("currency", request.getCurrency());
        
        String url = riskServiceUrl + "/risk/check?transferId=" + transferId;
        ResponseEntity<Result<Map<String, String>>> response = restTemplate.exchange(
                url,
                HttpMethod.POST,
                new HttpEntity<>(riskRequest),
                new ParameterizedTypeReference<Result<Map<String, String>>>() {}
        );
        
        if (response.getBody() == null || response.getBody().getData() == null) {
            throw new BusinessException("风控服务调用失败");
        }
        
        String result = response.getBody().getData().get("result");
        if (!"ALLOW".equals(result)) {
            String reasonCode = response.getBody().getData().get("reasonCode");
            throw new BusinessException("风控拒绝: " + reasonCode);
        }
        
        log.info("风控检查通过: transferId={}", transferId);
    }

    /**
     * 扣款
     */
    private void debitAccount(CreateTransferRequest request, String transferId) {
        log.info("调用账户服务扣款: transferId={}", transferId);
        
        Map<String, Object> debitRequest = new HashMap<>();
        debitRequest.put("accountId", request.getFromAccountId());
        debitRequest.put("amount", request.getAmount());
        debitRequest.put("currency", request.getCurrency());
        debitRequest.put("transactionId", transferId);
        
        String url = accountServiceUrl + "/internal/accounts/debit";
        restTemplate.postForObject(url, debitRequest, Result.class);
        
        log.info("扣款成功: transferId={}", transferId);
    }

    /**
     * 入账
     */
    private void creditAccount(CreateTransferRequest request, String transferId) {
        log.info("调用账户服务入账: transferId={}", transferId);

        Map<String, Object> creditRequest = new HashMap<>();
        creditRequest.put("accountId", request.getToAccountId());
        creditRequest.put("amount", request.getAmount());
        creditRequest.put("currency", request.getCurrency());
        creditRequest.put("transactionId", transferId);

        String url = accountServiceUrl + "/internal/accounts/credit";
        restTemplate.postForObject(url, creditRequest, Result.class);

        log.info("入账成功: transferId={}", transferId);
    }

    /**
     * 总账记账
     */
    private void postLedger(CreateTransferRequest request, String transferId) {
        log.info("调用总账服务记账: transferId={}", transferId);

        Map<String, Object> ledgerRequest = new HashMap<>();
        ledgerRequest.put("transactionId", transferId);

        List<Map<String, Object>> entries = new ArrayList<>();

        // 借方分录
        Map<String, Object> debitEntry = new HashMap<>();
        debitEntry.put("ledgerAccountCode", "CASH");
        debitEntry.put("debitAmount", request.getAmount());
        debitEntry.put("creditAmount", null);
        entries.add(debitEntry);

        // 贷方分录
        Map<String, Object> creditEntry = new HashMap<>();
        creditEntry.put("ledgerAccountCode", "CUSTOMER_DEPOSIT");
        creditEntry.put("debitAmount", null);
        creditEntry.put("creditAmount", request.getAmount());
        entries.add(creditEntry);

        ledgerRequest.put("entries", entries);

        String url = ledgerServiceUrl + "/entries";
        restTemplate.postForObject(url, ledgerRequest, Result.class);

        log.info("总账记账成功: transferId={}", transferId);
    }

    /**
     * 发送通知
     */
    private void sendNotification(CreateTransferRequest request, String transferId) {
        log.info("调用通知服务: transferId={}", transferId);

        Map<String, Object> notifyRequest = new HashMap<>();
        notifyRequest.put("transferId", transferId);
        notifyRequest.put("customerId", "C001"); // 简化处理
        notifyRequest.put("channel", "SMS");
        notifyRequest.put("templateCode", "TRANSFER_SUCCESS");

        Map<String, Object> params = new HashMap<>();
        params.put("amount", request.getAmount());
        params.put("toAccount", request.getToAccountId());
        notifyRequest.put("params", params);

        String url = notificationServiceUrl + "/notify";
        restTemplate.postForObject(url, notifyRequest, Result.class);

        log.info("通知发送成功: transferId={}", transferId);
    }

    /**
     * 更新转账状态
     */
    private void updateStatus(Transfer transfer, TransferStatus status) {
        transfer.setStatus(status);
        transfer.setLastUpdatedAt(LocalDateTime.now());
        transferMapper.updateById(transfer);
        log.info("转账状态更新: transferId={}, status={}", transfer.getId(), status);
    }
}

