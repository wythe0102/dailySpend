package com.dailyspend.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class DailySpendDTO {
    private Long spendDetailId;
    private Long typeId;
    private BigDecimal amount;
    private String demo;
    private Long userId;
    private LocalDate date;
}