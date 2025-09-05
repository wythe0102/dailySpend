package com.dailyspend.service;

import com.dailyspend.dto.DailyWeightDTO;
import com.dailyspend.entity.DailyWeight;
import com.dailyspend.repository.DailyWeightRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DailyWeightService {
    
    private final DailyWeightRepository dailyWeightRepository;
    
    public List<DailyWeightDTO> findAll() {
        return dailyWeightRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    public List<DailyWeightDTO> findByUserId(Long userId) {
        return dailyWeightRepository.findByUser_UserIdOrderByTimeDesc(userId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    public List<DailyWeightDTO> findByUserIdAndTimeRange(Long userId, LocalDateTime startTime, LocalDateTime endTime) {
        return dailyWeightRepository.findByUser_UserIdAndTimeBetweenOrderByTimeDesc(userId, startTime, endTime).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    public DailyWeight save(DailyWeight dailyWeight) {
        return dailyWeightRepository.save(dailyWeight);
    }
    
    public java.util.Optional<DailyWeight> findById(Long id) {
        return dailyWeightRepository.findById(id);
    }
    
    public void deleteById(Long id) {
        dailyWeightRepository.deleteById(id);
    }
    
    private DailyWeightDTO convertToDTO(DailyWeight dailyWeight) {
        DailyWeightDTO dto = new DailyWeightDTO();
        dto.setWeightId(dailyWeight.getWeightId());
        dto.setWeightAmount(dailyWeight.getWeightAmount());
        dto.setTime(dailyWeight.getTime());
        if (dailyWeight.getUser() != null) {
            dto.setUserId(dailyWeight.getUser().getUserId());
            dto.setUserName(dailyWeight.getUser().getName());
        }
        return dto;
    }
}