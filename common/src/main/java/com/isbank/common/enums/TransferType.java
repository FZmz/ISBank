package com.isbank.common.enums;

/**
 * 转账类型枚举
 */
public enum TransferType {
    INTERNAL("行内转账"),
    EXTERNAL("跨行转账");

    private final String description;

    TransferType(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}

