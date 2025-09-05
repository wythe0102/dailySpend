package com.dailyspend.entity;

import javax.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "daily_spend")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DailySpend {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "spendDetailId")
    private Long spendDetailId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "typeId")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Type type;
    
    private BigDecimal amount;
    
    @Column(length = 20000)
    private String demo;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "userId")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private User user;
    
    private LocalDate date;
}