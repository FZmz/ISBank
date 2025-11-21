package com.isbank.ledger.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.isbank.common.exception.BusinessException;
import com.isbank.ledger.dto.PostEntriesRequest;
import com.isbank.ledger.entity.LedgerAccount;
import com.isbank.ledger.entity.LedgerEntry;
import com.isbank.ledger.mapper.LedgerAccountMapper;
import com.isbank.ledger.mapper.LedgerEntryMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 总账服务
 */
@Slf4j
@Service
public class LedgerService {

    @Autowired
    private LedgerEntryMapper ledgerEntryMapper;

    @Autowired
    private LedgerAccountMapper ledgerAccountMapper;

    /**
     * 记账
     */
    @Transactional(rollbackFor = Exception.class)
    public void postEntries(PostEntriesRequest request) {
        log.info("开始记账: transactionId={}", request.getTransactionId());
        
        BigDecimal totalDebit = BigDecimal.ZERO;
        BigDecimal totalCredit = BigDecimal.ZERO;
        
        // 插入分录并计算借贷总额
        for (PostEntriesRequest.EntryItem item : request.getEntries()) {
            // 查找总账科目
            LambdaQueryWrapper<LedgerAccount> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(LedgerAccount::getCode, item.getLedgerAccountCode());
            LedgerAccount account = ledgerAccountMapper.selectOne(wrapper);
            
            if (account == null) {
                throw new BusinessException("总账科目不存在: " + item.getLedgerAccountCode());
            }
            
            // 创建分录
            LedgerEntry entry = new LedgerEntry();
            entry.setTransactionId(request.getTransactionId());
            entry.setLedgerAccountId(account.getId());
            entry.setDebitAmount(item.getDebitAmount());
            entry.setCreditAmount(item.getCreditAmount());
            entry.setOccurredAt(LocalDateTime.now());
            ledgerEntryMapper.insert(entry);
            
            // 累计借贷金额
            if (item.getDebitAmount() != null) {
                totalDebit = totalDebit.add(item.getDebitAmount());
            }
            if (item.getCreditAmount() != null) {
                totalCredit = totalCredit.add(item.getCreditAmount());
            }
        }
        
        // 检查借贷平衡
        if (totalDebit.compareTo(totalCredit) != 0) {
            throw new BusinessException("借贷不平衡: debit=" + totalDebit + ", credit=" + totalCredit);
        }
        
        log.info("记账成功: transactionId={}, debit={}, credit={}", 
                request.getTransactionId(), totalDebit, totalCredit);
    }

    /**
     * 查询交易分录
     */
    public List<LedgerEntry> getEntriesByTransactionId(String transactionId) {
        LambdaQueryWrapper<LedgerEntry> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(LedgerEntry::getTransactionId, transactionId);
        return ledgerEntryMapper.selectList(wrapper);
    }
}

