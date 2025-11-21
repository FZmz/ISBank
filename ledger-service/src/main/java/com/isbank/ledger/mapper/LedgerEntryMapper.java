package com.isbank.ledger.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.isbank.ledger.entity.LedgerEntry;
import org.apache.ibatis.annotations.Mapper;

/**
 * 总账分录Mapper
 */
@Mapper
public interface LedgerEntryMapper extends BaseMapper<LedgerEntry> {
}

