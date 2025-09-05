package com.dailyspend.repository;

import com.dailyspend.entity.DailyWeight;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface DailyWeightRepository extends JpaRepository<DailyWeight, Long> {
    
    List<DailyWeight> findAllByOrderByTimeDesc();
    
    List<DailyWeight> findByUser_UserIdOrderByTimeDesc(Long userId);
    
    List<DailyWeight> findByUser_UserIdAndTimeBetweenOrderByTimeDesc(Long userId, LocalDateTime startTime, LocalDateTime endTime);
}