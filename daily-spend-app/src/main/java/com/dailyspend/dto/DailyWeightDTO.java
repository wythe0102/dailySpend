package com.dailyspend.dto;

import java.time.LocalDateTime;

public class DailyWeightDTO {
    private Long weightId;
    private Long userId;
    private String userName;
    private Double weightAmount;
    private LocalDateTime time;

    public DailyWeightDTO() {}

    public DailyWeightDTO(Long weightId, Long userId, String userName, Double weightAmount, LocalDateTime time) {
        this.weightId = weightId;
        this.userId = userId;
        this.userName = userName;
        this.weightAmount = weightAmount;
        this.time = time;
    }

    // Getters and Setters
    public Long getWeightId() {
        return weightId;
    }

    public void setWeightId(Long weightId) {
        this.weightId = weightId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public Double getWeightAmount() {
        return weightAmount;
    }

    public void setWeightAmount(Double weightAmount) {
        this.weightAmount = weightAmount;
    }

    public LocalDateTime getTime() {
        return time;
    }

    public void setTime(LocalDateTime time) {
        this.time = time;
    }
}