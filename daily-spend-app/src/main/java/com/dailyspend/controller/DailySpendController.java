package com.dailyspend.controller;

import com.dailyspend.dto.DailySpendDTO;
import com.dailyspend.entity.DailySpend;
import com.dailyspend.entity.Type;
import com.dailyspend.entity.User;
import com.dailyspend.service.DailySpendService;
import com.dailyspend.service.TypeService;
import com.dailyspend.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Arrays;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/daily-spends")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class DailySpendController {
    
    private final DailySpendService dailySpendService;
    private final TypeService typeService;
    private final UserService userService;
    
    @GetMapping
    public List<DailySpend> getAll() {
        return dailySpendService.findAll();
    }
    
    @GetMapping("/user/{userId}")
    public List<DailySpend> getByUserId(@PathVariable Long userId) {
        return dailySpendService.findByUserId(userId);
    }
    
    @GetMapping("/page")
    public ResponseEntity<Page<DailySpend>> getDailySpendsByPage(
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) Long typeId,
            @RequestParam(required = false) String typeIds,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "date"));

        // 处理用户ID为空的情况（查询所有用户数据）
        if (userId == null) {
            if (startDate != null && endDate != null) {
                if (typeIds != null && !typeIds.trim().isEmpty()) {
                    List<Long> typeIdList = java.util.Arrays.stream(typeIds.split(","))
                            .map(String::trim)
                            .map(Long::parseLong)
                            .collect(java.util.stream.Collectors.toList());
                    return ResponseEntity.ok(dailySpendService.findByTypeIdsAndDateBetween(typeIdList, startDate, endDate, pageable));
                } else if (typeId != null) {
                    return ResponseEntity.ok(dailySpendService.findByTypeIdAndDateBetween(typeId, startDate, endDate, pageable));
                } else {
                    return ResponseEntity.ok(dailySpendService.findByDateBetween(startDate, endDate, pageable));
                }
            } else {
                if (typeIds != null && !typeIds.trim().isEmpty()) {
                    List<Long> typeIdList = java.util.Arrays.stream(typeIds.split(","))
                            .map(String::trim)
                            .map(Long::parseLong)
                            .collect(java.util.stream.Collectors.toList());
                    return ResponseEntity.ok(dailySpendService.findByTypeIds(typeIdList, pageable));
                } else if (typeId != null) {
                    return ResponseEntity.ok(dailySpendService.findByTypeId(typeId, pageable));
                } else {
                    return ResponseEntity.ok(dailySpendService.findAll(pageable));
                }
            }
        }

        // 原有逻辑：按用户ID查询
        if (startDate != null && endDate != null) {
            if (typeIds != null && !typeIds.trim().isEmpty()) {
                List<Long> typeIdList = java.util.Arrays.stream(typeIds.split(","))
                        .map(String::trim)
                        .map(Long::parseLong)
                        .collect(java.util.stream.Collectors.toList());
                return ResponseEntity.ok(dailySpendService.findByUserIdAndTypeIdsAndDateBetween(userId, typeIdList, startDate, endDate, pageable));
            } else if (typeId != null) {
                return ResponseEntity.ok(dailySpendService.findByUserIdAndTypeIdAndDateBetween(userId, typeId, startDate, endDate, pageable));
            } else {
                return ResponseEntity.ok(dailySpendService.findByUserIdAndDateBetween(userId, startDate, endDate, pageable));
            }
        } else {
            if (typeIds != null && !typeIds.trim().isEmpty()) {
                List<Long> typeIdList = java.util.Arrays.stream(typeIds.split(","))
                        .map(String::trim)
                        .map(Long::parseLong)
                        .collect(java.util.stream.Collectors.toList());
                return ResponseEntity.ok(dailySpendService.findByUserIdAndTypeIds(userId, typeIdList, pageable));
            } else if (typeId != null) {
                return ResponseEntity.ok(dailySpendService.findByUserIdAndTypeId(userId, typeId, pageable));
            } else {
                return ResponseEntity.ok(dailySpendService.findByUserId(userId, pageable));
            }
        }
    }
    
    @GetMapping("/user/{userId}/date-range")
    public List<DailySpend> getByUserIdAndDateRange(
            @PathVariable Long userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return dailySpendService.findByUserIdAndDateRange(userId, startDate, endDate);
    }
    
    @GetMapping("/total/user/{userId}/date-range")
    public BigDecimal getTotalByUserAndDateRange(
            @PathVariable Long userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return dailySpendService.getTotalByUserAndDateRange(userId, startDate, endDate);
    }
    
    @PostMapping
    public DailySpend create(@RequestBody DailySpendDTO dailySpendDTO) {
        DailySpend dailySpend = new DailySpend();
        dailySpend.setAmount(dailySpendDTO.getAmount());
        dailySpend.setDate(dailySpendDTO.getDate());
        dailySpend.setDemo(dailySpendDTO.getDemo());
        
        // 设置关联对象
        Type type = typeService.findById(dailySpendDTO.getTypeId())
            .orElseThrow(() -> new RuntimeException("类型不存在"));
        User user = userService.findById(dailySpendDTO.getUserId())
            .orElseThrow(() -> new RuntimeException("用户不存在"));
        
        dailySpend.setType(type);
        dailySpend.setUser(user);
        
        return dailySpendService.save(dailySpend);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<DailySpend> update(@PathVariable Long id, @RequestBody DailySpendDTO dailySpendDTO) {
        DailySpend dailySpend = dailySpendService.findById(id)
            .orElseThrow(() -> new RuntimeException("记录不存在"));
        
        dailySpend.setAmount(dailySpendDTO.getAmount());
        dailySpend.setDate(dailySpendDTO.getDate());
        dailySpend.setDemo(dailySpendDTO.getDemo());
        
        // 更新关联对象
        Type type = typeService.findById(dailySpendDTO.getTypeId())
            .orElseThrow(() -> new RuntimeException("类型不存在"));
        User user = userService.findById(dailySpendDTO.getUserId())
            .orElseThrow(() -> new RuntimeException("用户不存在"));
        
        dailySpend.setType(type);
        dailySpend.setUser(user);
        
        return ResponseEntity.ok(dailySpendService.save(dailySpend));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        dailySpendService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}