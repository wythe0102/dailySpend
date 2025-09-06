package com.dailyspend.entity;

import javax.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "type")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Type {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "typeId")
    private Long typeId;
    
    @Column(length = 200)
    private String name;
    
    @Column(length = 40)
    private String code;
    
    @Column(name = "addDate")
    private LocalDateTime addDate;
    
    @Column(name = "parentId")
    private Long parentId;
    
    @Column(name = "sequence")
    private Integer sequence = 0;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parentId", insertable = false, updatable = false)
    @JsonIgnore
    private Type parent;
    
    @OneToMany(mappedBy = "parent", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnore
    private List<Type> children;
    
    @OneToMany(mappedBy = "type", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnore
    private List<DailySpend> dailySpends;
    
    @OneToMany(mappedBy = "type", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnore
    private List<Budget> budgets;
    
    @PrePersist
    public void prePersist() {
        this.addDate = LocalDateTime.now();
    }
}