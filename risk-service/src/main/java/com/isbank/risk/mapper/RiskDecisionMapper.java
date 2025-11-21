package com.isbank.risk.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.isbank.risk.entity.RiskDecision;
import org.apache.ibatis.annotations.Mapper;

/**
 * 风控决策Mapper
 */
@Mapper
public interface RiskDecisionMapper extends BaseMapper<RiskDecision> {
}

