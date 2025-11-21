package com.isbank.transfer.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.isbank.transfer.entity.Transfer;
import org.apache.ibatis.annotations.Mapper;

/**
 * 转账Mapper
 */
@Mapper
public interface TransferMapper extends BaseMapper<Transfer> {
}

