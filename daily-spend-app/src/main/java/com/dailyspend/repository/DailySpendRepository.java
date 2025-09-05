package com.dailyspend.repository;

import com.dailyspend.entity.DailySpend;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface DailySpendRepository extends JpaRepository<DailySpend, Long> {
    
    List<DailySpend> findByUser_UserIdOrderByDateDesc(Long userId);
    
    Page<DailySpend> findByUser_UserId(Long userId, Pageable pageable);
    
    Page<DailySpend> findByUser_UserIdAndType_TypeId(Long userId, Long typeId, Pageable pageable);
    
    Page<DailySpend> findByUser_UserIdAndType_TypeIdIn(Long userId, List<Long> typeIds, Pageable pageable);
    
    Page<DailySpend> findByUser_UserIdAndDateBetween(Long userId, LocalDate startDate, LocalDate endDate, Pageable pageable);
    
    Page<DailySpend> findByUser_UserIdAndType_TypeIdAndDateBetween(Long userId, Long typeId, LocalDate startDate, LocalDate endDate, Pageable pageable);
    
    Page<DailySpend> findByUser_UserIdAndType_TypeIdInAndDateBetween(Long userId, List<Long> typeIds, LocalDate startDate, LocalDate endDate, Pageable pageable);
    
    List<DailySpend> findByUser_UserIdAndDateBetweenOrderByDateDesc(Long userId, LocalDate startDate, LocalDate endDate);
    
    List<DailySpend> findByType_TypeIdAndDateBetween(Long typeId, LocalDate startDate, LocalDate endDate);
    
    @Query("SELECT SUM(d.amount) FROM DailySpend d WHERE d.type.typeId = :typeId AND d.date BETWEEN :startDate AND :endDate")
    BigDecimal sumAmountByTypeAndDateBetween(@Param("typeId") Long typeId, @Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    @Query("SELECT SUM(d.amount) FROM DailySpend d WHERE d.user.userId = :userId AND d.date BETWEEN :startDate AND :endDate")
    BigDecimal sumAmountByUserAndDateBetween(@Param("userId") Long userId, @Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
}