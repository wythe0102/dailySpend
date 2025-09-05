package com.dailyspend.entity;

import javax.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "budget")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Budget {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "budgetId")
    private Long budgetId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "typeId")
    private Type type;
    
    @Column(name = "startDate")
    private LocalDate startDate;
    
    @Column(name = "endDate")
    private LocalDate endDate;
    
    @Column(name = "budgetAmount", precision = 18)
    private BigDecimal budgetAmount;
    
    @Column(name = "realAmount", precision = 18)
    private BigDecimal realAmount;
    
    @Column(name = "difference", precision = 18)
    private BigDecimal difference;
    
    @Column(name = "lastUpdate")
    private LocalDateTime lastUpdate;
    
    @Column(name = "realPercent")
    private Double realPercent;
    
    @Column(name = "remarks", length = 65535)
    private String remarks;
}