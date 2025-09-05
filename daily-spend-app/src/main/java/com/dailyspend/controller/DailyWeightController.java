package com.dailyspend.controller;

import com.dailyspend.dto.DailyWeightDTO;
import com.dailyspend.entity.DailyWeight;
import com.dailyspend.service.DailyWeightService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/daily-weights")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class DailyWeightController {
    
    private final DailyWeightService dailyWeightService;
    
    @GetMapping
    public List<DailyWeightDTO> getAll() {
        return dailyWeightService.findAll();
    }
    
    @GetMapping("/user/{userId}")
    public List<DailyWeightDTO> getByUserId(@PathVariable Long userId) {
        return dailyWeightService.findByUserId(userId);
    }
    
    @GetMapping("/user/{userId}/time-range")
    public List<DailyWeightDTO> getByUserIdAndTimeRange(
            @PathVariable Long userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime) {
        return dailyWeightService.findByUserIdAndTimeRange(userId, startTime, endTime);
    }
    
    @PostMapping
    public DailyWeight create(@RequestBody DailyWeight dailyWeight) {
        return dailyWeightService.save(dailyWeight);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<DailyWeight> update(@PathVariable Long id, @RequestBody DailyWeight dailyWeight) {
        dailyWeight.setWeightId(id);
        return ResponseEntity.ok(dailyWeightService.save(dailyWeight));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        dailyWeightService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}