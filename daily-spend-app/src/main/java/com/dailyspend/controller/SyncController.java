package com.dailyspend.controller;

import com.dailyspend.dto.SyncDailySpendDTO;
import com.dailyspend.service.SyncService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/daily-spends")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class SyncController {
    
    private final SyncService syncService;
    
    @PostMapping("/sync")
    public ResponseEntity<List<Long>> syncDailySpends() {
        try {
            List<Long> syncedIds = syncService.syncDailySpends();
            return ResponseEntity.ok(syncedIds);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(null);
        }
    }
    
    @PostMapping("/confirm-sync")
    public ResponseEntity<String> confirmSync(@RequestBody List<Long> dailySpendIds) {
        try {
            String result = syncService.confirmSync(dailySpendIds);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("确认同步失败: " + e.getMessage());
        }
    }
}