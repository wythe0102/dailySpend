package com.dailyspend.entity;

import javax.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDate;
import java.util.List;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "userId")
    private Long userId;
    
    @Column(length = 40)
    private String name;
    
    @Column(length = 40, unique = true)
    private String username;
    
    @Column(length = 400)
    private String password;
    
    @Column(length = 10)
    private String sex;
    
    @Column(length = 20000)
    private String demo;
    
    @Column(name = "birthday")
    private LocalDate birthday;
    
    @Column(name = "IdNum", length = 40)
    private String idNum;
    
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnore
    private List<DailySpend> dailySpends;
    
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnore
    private List<DailyWeight> dailyWeights;
}