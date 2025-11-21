package com.isbank.account.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.isbank.account.dto.CreditRequest;
import com.isbank.account.dto.CreateAccountRequest;
import com.isbank.account.dto.DebitRequest;
import com.isbank.account.entity.Account;
import com.isbank.account.entity.AccountLedger;
import com.isbank.account.mapper.AccountLedgerMapper;
import com.isbank.account.mapper.AccountMapper;
import com.isbank.common.enums.AccountStatus;
import com.isbank.common.enums.Direction;
import com.isbank.common.exception.BusinessException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * 账户服务
 */
@Slf4j
@Service
public class AccountService {

    @Autowired
    private AccountMapper accountMapper;

    @Autowired
    private AccountLedgerMapper accountLedgerMapper;

    /**
     * 创建账户
     */
    @Transactional(rollbackFor = Exception.class)
    public Account createAccount(CreateAccountRequest request) {
        Account account = new Account();
        account.setCustomerId(request.getCustomerId());
        account.setAccountNo(generateAccountNo());
        account.setCurrency(request.getCurrency());
        account.setBalance(BigDecimal.ZERO);
        account.setStatus(AccountStatus.ACTIVE);
        account.setCreatedAt(LocalDateTime.now());
        account.setUpdatedAt(LocalDateTime.now());
        
        accountMapper.insert(account);
        log.info("创建账户成功: accountId={}, accountNo={}", account.getId(), account.getAccountNo());
        return account;
    }

    /**
     * 查询所有账户
     */
    public List<Account> getAllAccounts() {
        List<Account> accounts = accountMapper.selectList(null);
        log.info("查询所有账户: count={}", accounts.size());
        return accounts;
    }

    /**
     * 查询账户
     */
    public Account getAccount(Long accountId) {
        Account account = accountMapper.selectById(accountId);
        if (account == null) {
            throw new BusinessException("账户不存在");
        }
        return account;
    }

    /**
     * 根据账户号查询账户
     */
    public Account getAccountByNo(String accountNo) {
        LambdaQueryWrapper<Account> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Account::getAccountNo, accountNo);
        Account account = accountMapper.selectOne(wrapper);
        if (account == null) {
            throw new BusinessException("账户不存在");
        }
        return account;
    }

    /**
     * 查询账户分户账
     */
    public List<AccountLedger> getAccountLedger(Long accountId) {
        LambdaQueryWrapper<AccountLedger> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(AccountLedger::getAccountId, accountId);
        wrapper.orderByDesc(AccountLedger::getOccurredAt);
        return accountLedgerMapper.selectList(wrapper);
    }

    /**
     * 冻结账户
     */
    @Transactional(rollbackFor = Exception.class)
    public void freezeAccount(Long accountId) {
        Account account = getAccount(accountId);
        account.setStatus(AccountStatus.FROZEN);
        account.setUpdatedAt(LocalDateTime.now());
        accountMapper.updateById(account);
        log.info("冻结账户成功: accountId={}", accountId);
    }

    /**
     * 解冻账户
     */
    @Transactional(rollbackFor = Exception.class)
    public void unfreezeAccount(Long accountId) {
        Account account = getAccount(accountId);
        account.setStatus(AccountStatus.ACTIVE);
        account.setUpdatedAt(LocalDateTime.now());
        accountMapper.updateById(account);
        log.info("解冻账户成功: accountId={}", accountId);
    }

    /**
     * 扣款
     */
    @Transactional(rollbackFor = Exception.class)
    public void debit(DebitRequest request) {
        Account account = getAccount(request.getAccountId());
        
        // 检查账户状态
        if (account.getStatus() != AccountStatus.ACTIVE) {
            throw new BusinessException("账户状态异常,无法扣款");
        }
        
        // 检查余额
        if (account.getBalance().compareTo(request.getAmount()) < 0) {
            throw new BusinessException("账户余额不足");
        }
        
        // 更新余额
        BigDecimal newBalance = account.getBalance().subtract(request.getAmount());
        account.setBalance(newBalance);
        account.setUpdatedAt(LocalDateTime.now());
        accountMapper.updateById(account);
        
        // 记录分户账
        AccountLedger ledger = new AccountLedger();
        ledger.setAccountId(account.getId());
        ledger.setTransactionId(request.getTransactionId());
        ledger.setDirection(Direction.DEBIT);
        ledger.setAmount(request.getAmount());
        ledger.setBalanceAfter(newBalance);
        ledger.setOccurredAt(LocalDateTime.now());
        accountLedgerMapper.insert(ledger);
        
        log.info("扣款成功: accountId={}, amount={}, balance={}", 
                account.getId(), request.getAmount(), newBalance);
    }

    /**
     * 入账
     */
    @Transactional(rollbackFor = Exception.class)
    public void credit(CreditRequest request) {
        Account account = getAccount(request.getAccountId());
        
        // 检查账户状态
        if (account.getStatus() != AccountStatus.ACTIVE) {
            throw new BusinessException("账户状态异常,无法入账");
        }
        
        // 更新余额
        BigDecimal newBalance = account.getBalance().add(request.getAmount());
        account.setBalance(newBalance);
        account.setUpdatedAt(LocalDateTime.now());
        accountMapper.updateById(account);
        
        // 记录分户账
        AccountLedger ledger = new AccountLedger();
        ledger.setAccountId(account.getId());
        ledger.setTransactionId(request.getTransactionId());
        ledger.setDirection(Direction.CREDIT);
        ledger.setAmount(request.getAmount());
        ledger.setBalanceAfter(newBalance);
        ledger.setOccurredAt(LocalDateTime.now());
        accountLedgerMapper.insert(ledger);
        
        log.info("入账成功: accountId={}, amount={}, balance={}", 
                account.getId(), request.getAmount(), newBalance);
    }

    /**
     * 生成账户号
     */
    private String generateAccountNo() {
        return "ACC" + System.currentTimeMillis() + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}

