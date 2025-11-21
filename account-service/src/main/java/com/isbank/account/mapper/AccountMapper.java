package com.isbank.account.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.isbank.account.entity.Account;
import org.apache.ibatis.annotations.Mapper;

/**
 * 账户Mapper
 */
@Mapper
public interface AccountMapper extends BaseMapper<Account> {
}

