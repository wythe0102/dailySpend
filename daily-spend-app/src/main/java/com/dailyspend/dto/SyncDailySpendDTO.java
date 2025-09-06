package com.dailyspend.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SyncDailySpendDTO {
    private Long spendDetailId;
    private Long typeId;
    private Long userId;
    private BigDecimal amount;
    private String demo;
    private LocalDate date;
}