package com.dailyspend.controller;

import com.dailyspend.dto.DailyWeightDTO;
import com.dailyspend.entity.DailyWeight;
import com.dailyspend.entity.User;
import com.dailyspend.service.DailyWeightService;
import com.dailyspend.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
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
    private final UserService userService;
    
    @GetMapping
    public ResponseEntity<List<DailyWeightDTO>> getAll() {
        return ResponseEntity.ok(dailyWeightService.findAll());
    }

    @GetMapping("/page")
    public ResponseEntity<Page<DailyWeightDTO>> getAllPageable(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime) {
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "time"));
        
        if (startTime != null && endTime != null) {
            return ResponseEntity.ok(dailyWeightService.findByTimeRange(startTime, endTime, pageable));
        } else {
            return ResponseEntity.ok(dailyWeightService.findAll(pageable));
        }
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<DailyWeightDTO>> getByUserId(@PathVariable Long userId) {
        return ResponseEntity.ok(dailyWeightService.findByUserId(userId));
    }

    @GetMapping("/user/{userId}/page")
    public ResponseEntity<Page<DailyWeightDTO>> getByUserIdPageable(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime) {
        
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "time"));
        
        if (startTime != null && endTime != null) {
            return ResponseEntity.ok(dailyWeightService.findByUserIdAndTimeRange(userId, startTime, endTime, pageable));
        } else {
            return ResponseEntity.ok(dailyWeightService.findByUserId(userId, pageable));
        }
    }

    @GetMapping("/user/{userId}/time-range")
    public ResponseEntity<List<DailyWeightDTO>> getByUserIdAndTimeRange(
            @PathVariable Long userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime) {
        return ResponseEntity.ok(dailyWeightService.findByUserIdAndTimeRange(userId, startTime, endTime));
    }
    
    @PostMapping
    public DailyWeightDTO create(@RequestBody DailyWeightDTO dailyWeightDTO) {
        DailyWeight dailyWeight = new DailyWeight();
        dailyWeight.setWeightAmount(dailyWeightDTO.getWeightAmount());
        dailyWeight.setTime(dailyWeightDTO.getTime());
        
        // 设置关联用户
        User user = userService.findById(dailyWeightDTO.getUserId())
            .orElseThrow(() -> new RuntimeException("用户不存在"));
        dailyWeight.setUser(user);
        
        DailyWeight saved = dailyWeightService.save(dailyWeight);
        return dailyWeightService.findAll().stream()
            .filter(dto -> dto.getWeightId().equals(saved.getWeightId()))
            .findFirst()
            .orElse(null);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<DailyWeightDTO> update(@PathVariable Long id, @RequestBody DailyWeightDTO dailyWeightDTO) {
        DailyWeight dailyWeight = dailyWeightService.findById(id)
            .orElseThrow(() -> new RuntimeException("记录不存在"));
        
        dailyWeight.setWeightAmount(dailyWeightDTO.getWeightAmount());
        dailyWeight.setTime(dailyWeightDTO.getTime());
        
        // 更新关联用户
        User user = userService.findById(dailyWeightDTO.getUserId())
            .orElseThrow(() -> new RuntimeException("用户不存在"));
        dailyWeight.setUser(user);
        
        DailyWeight saved = dailyWeightService.save(dailyWeight);
        return dailyWeightService.findAll().stream()
            .filter(dto -> dto.getWeightId().equals(saved.getWeightId()))
            .findFirst()
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        dailyWeightService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}