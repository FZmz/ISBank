package com.isbank.common.enums;

/**
 * 转账状态枚举
 */
public enum TransferStatus {
    INIT("初始化"),
    PENDING("待处理"),
    RISK_CHECKING("风控检查中"),
    RISK_PASSED("风控通过"),
    RISK_REJECTED("风控拒绝"),
    DEBIT_DONE("扣款完成"),
    CREDIT_DONE("入账完成"),
    LEDGER_POSTED("总账记账完成"),
    SUCCESS("成功"),
    FAILED("失败");

    private final String description;

    TransferStatus(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}

