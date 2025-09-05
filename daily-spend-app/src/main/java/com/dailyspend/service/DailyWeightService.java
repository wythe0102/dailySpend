package com.dailyspend.service;

import com.dailyspend.entity.DailyWeight;
import com.dailyspend.repository.DailyWeightRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DailyWeightService {
    
    private final DailyWeightRepository dailyWeightRepository;
    
    public List<DailyWeight> findAll() {
        return dailyWeightRepository.findAll();
    }
    
    public List<DailyWeight> findByUserId(Long userId) {
        return dailyWeightRepository.findByUser_UserIdOrderByTimeDesc(userId);
    }
    
    public List<DailyWeight> findByUserIdAndTimeRange(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        return dailyWeightRepository.findByUser_UserIdAndTimeBetweenOrderByTimeDesc(userId, startTime, endTime);
    }
    
    public DailyWeight save(DailyWeight dailyWeight) {
        return dailyWeightRepository.save(dailyWeight);
    }
    
    public void deleteById(Long id) {
        dailyWeightRepository.deleteById(id);
    }
}