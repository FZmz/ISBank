package com.isbank.common.enums;

/**
 * 借贷方向枚举
 */
public enum Direction {
    DEBIT("借方"),
    CREDIT("贷方");

    private final String description;

    Direction(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}

