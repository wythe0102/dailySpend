package com.dailyspend.repository;

import com.dailyspend.entity.Budget;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface BudgetRepository extends JpaRepository<Budget, Long> {
    
    List<Budget> findByType_TypeIdOrderByStartDateDesc(Long typeId);
    
    List<Budget> findByStartDateBetweenOrderByStartDateDesc(LocalDate startDate, LocalDate endDate);
    
    @Query("SELECT b FROM Budget b WHERE b.type.typeId = :typeId AND b.startDate <= :date AND b.endDate >= :date")
    List<Budget> findByTypeAndDateInRange(@Param("typeId") Long typeId, @Param("date") LocalDate date);
}