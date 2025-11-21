package com.isbank.common.enums;

/**
 * 账户状态枚举
 */
public enum AccountStatus {
    ACTIVE("激活"),
    FROZEN("冻结"),
    CLOSED("关闭");

    private final String description;

    AccountStatus(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}

