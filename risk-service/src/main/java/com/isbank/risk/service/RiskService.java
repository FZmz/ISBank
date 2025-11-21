package com.isbank.risk.service;

import com.isbank.risk.dto.RiskCheckRequest;
import com.isbank.risk.dto.RiskCheckResponse;
import com.isbank.risk.entity.RiskDecision;
import com.isbank.risk.mapper.RiskDecisionMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 风控服务
 */
@Slf4j
@Service
public class RiskService {

    @Autowired
    private RiskDecisionMapper riskDecisionMapper;

    // 单笔限额
    private static final BigDecimal SINGLE_LIMIT = new BigDecimal("50000.00");

    /**
     * 风控检查
     */
    @Transactional(rollbackFor = Exception.class)
    public RiskCheckResponse checkRisk(RiskCheckRequest request, String transferId) {
        log.info("开始风控检查: transferId={}, amount={}", transferId, request.getAmount());
        
        RiskCheckResponse response;
        
        // 检查单笔限额
        if (request.getAmount().compareTo(SINGLE_LIMIT) > 0) {
            response = RiskCheckResponse.deny("AMOUNT_LIMIT");
            log.warn("风控拒绝-超过单笔限额: transferId={}, amount={}, limit={}", 
                    transferId, request.getAmount(), SINGLE_LIMIT);
        } else {
            response = RiskCheckResponse.allow();
            log.info("风控通过: transferId={}", transferId);
        }
        
        // 保存风控决策
        RiskDecision decision = new RiskDecision();
        decision.setTransferId(transferId);
        decision.setResult(response.getResult());
        decision.setReasonCode(response.getReasonCode());
        decision.setCreatedAt(LocalDateTime.now());
        riskDecisionMapper.insert(decision);
        
        return response;
    }
}

