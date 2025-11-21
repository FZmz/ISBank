package com.isbank.account.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.isbank.account.entity.AccountLedger;
import org.apache.ibatis.annotations.Mapper;

/**
 * 账户分户账Mapper
 */
@Mapper
public interface AccountLedgerMapper extends BaseMapper<AccountLedger> {
}

