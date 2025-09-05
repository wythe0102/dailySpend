package com.dailyspend.service;

import com.dailyspend.entity.Budget;
import com.dailyspend.repository.BudgetRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class BudgetService {
    
    private final BudgetRepository budgetRepository;
    private final DailySpendService dailySpendService;
    
    public List<Budget> findAll() {
        return budgetRepository.findAll();
    }
    
    public List<Budget> findByDateRange(LocalDate startDate, LocalDate endDate) {
        return budgetRepository.findByStartDateBetweenOrderByStartDateDesc(startDate, endDate);
    }
    
    public List<Budget> findByTypeId(Long typeId) {
        return budgetRepository.findByType_TypeIdOrderByStartDateDesc(typeId);
    }
    
    public Budget save(Budget budget) {
        // 计算实际支出
        BigDecimal realAmount = dailySpendService.getTotalByTypeAndDateRange(
            budget.getType().getTypeId(), 
            budget.getStartDate(), 
            budget.getEndDate()
        );
        
        budget.setRealAmount(realAmount);
        budget.setDifference(budget.getBudgetAmount().subtract(realAmount));
        
        if (budget.getBudgetAmount().compareTo(BigDecimal.ZERO) > 0) {
            double percent = realAmount.divide(budget.getBudgetAmount(), 4, BigDecimal.ROUND_HALF_UP)
                .multiply(BigDecimal.valueOf(100)).doubleValue();
            budget.setRealPercent(percent);
        }
        
        return budgetRepository.save(budget);
    }
    
    public void deleteById(Long id) {
        budgetRepository.deleteById(id);
    }
}