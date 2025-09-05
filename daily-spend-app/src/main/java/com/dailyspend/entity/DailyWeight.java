package com.dailyspend.entity;

import javax.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "daily_weight")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DailyWeight {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "weightId")
    private Long weightId;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "userId")
    private User user;
    
    @Column(name = "weightAmount")
    private Double weightAmount;
    
    @Column(name = "time")
    private LocalDateTime time;
}