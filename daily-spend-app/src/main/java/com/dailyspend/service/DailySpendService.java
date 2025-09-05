package com.dailyspend.service;

import com.dailyspend.entity.DailySpend;
import com.dailyspend.repository.DailySpendRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DailySpendService {
    
    private final DailySpendRepository dailySpendRepository;
    
    public List<DailySpend> findAll() {
        return dailySpendRepository.findAll();
    }
    
    public List<DailySpend> findByUserId(Long userId) {
        return dailySpendRepository.findByUser_UserIdOrderByDateDesc(userId);
    }
    
    public Page<DailySpend> findByUserId(Long userId, Pageable pageable) {
        return dailySpendRepository.findByUser_UserId(userId, pageable);
    }
    
    public Page<DailySpend> findByUserIdAndTypeId(Long userId, Long typeId, Pageable pageable) {
        return dailySpendRepository.findByUser_UserIdAndType_TypeId(userId, typeId, pageable);
    }
    
    public Page<DailySpend> findByUserIdAndTypeIds(Long userId, List<Long> typeIds, Pageable pageable) {
        return dailySpendRepository.findByUser_UserIdAndType_TypeIdIn(userId, typeIds, pageable);
    }
    
    public List<DailySpend> findByUserIdAndDateRange(Long userId, LocalDate startDate, LocalDate endDate) {
        return dailySpendRepository.findByUser_UserIdAndDateBetweenOrderByDateDesc(userId, startDate, endDate);
    }
    
    public BigDecimal getTotalByTypeAndDateRange(Long typeId, LocalDate startDate, LocalDate endDate) {
        BigDecimal total = dailySpendRepository.sumAmountByTypeAndDateBetween(typeId, startDate, endDate);
        return total != null ? total : BigDecimal.ZERO;
    }
    
    public BigDecimal getTotalByUserAndDateRange(Long userId, LocalDate startDate, LocalDate endDate) {
        BigDecimal total = dailySpendRepository.sumAmountByUserAndDateBetween(userId, startDate, endDate);
        return total != null ? total : BigDecimal.ZERO;
    }
    
    public DailySpend save(DailySpend dailySpend) {
        return dailySpendRepository.save(dailySpend);
    }
    
    public void deleteById(Long id) {
        dailySpendRepository.deleteById(id);
    }
}