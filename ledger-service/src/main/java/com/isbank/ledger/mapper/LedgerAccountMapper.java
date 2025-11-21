package com.isbank.ledger.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.isbank.ledger.entity.LedgerAccount;
import org.apache.ibatis.annotations.Mapper;

/**
 * 总账科目Mapper
 */
@Mapper
public interface LedgerAccountMapper extends BaseMapper<LedgerAccount> {
}