package com.dailyspend.controller;

import com.dailyspend.entity.DailySpend;
import com.dailyspend.service.DailySpendService;
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
            @RequestParam Long userId,
            @RequestParam(required = false) Long typeId,
            @RequestParam(required = false) String typeIds,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "date"));

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
    public DailySpend create(@RequestBody DailySpend dailySpend) {
        return dailySpendService.save(dailySpend);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<DailySpend> update(@PathVariable Long id, @RequestBody DailySpend dailySpend) {
        dailySpend.setSpendDetailId(id);
        return ResponseEntity.ok(dailySpendService.save(dailySpend));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        dailySpendService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}