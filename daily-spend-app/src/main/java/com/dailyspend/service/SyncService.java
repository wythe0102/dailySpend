package com.dailyspend.service;

import com.dailyspend.dto.SyncDailySpendDTO;
import com.dailyspend.entity.DailySpend;
import com.dailyspend.entity.Type;
import com.dailyspend.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class SyncService {
    
    private final DailySpendService dailySpendService;
    private final TypeService typeService;
    private final UserService userService;
    private final RestTemplate restTemplate = new RestTemplate();
    
    private static final String SYNC_DOMAIN = "52tool.net";
    
    public List<Long> syncDailySpends() {
        List<Long> remoteIds = new ArrayList<>();
        List<Long> syncedLocalIds = new ArrayList<>();
        
        try {
            // 调用远程API获取同步数据
            String url = "http://" + SYNC_DOMAIN + "/rest/dailySpend/sync";
            SyncDailySpendDTO[] syncData = restTemplate.getForObject(url, SyncDailySpendDTO[].class);
            
            if (syncData != null && syncData.length > 0) {
                // 收集所有远程数据的ID
                for (SyncDailySpendDTO dto : syncData) {
                    remoteIds.add(dto.getSpendDetailId());
                }
                
                for (SyncDailySpendDTO dto : syncData) {
                    // 检查是否已存在相同记录
                    boolean exists = dailySpendService.findAll().stream()
                        .anyMatch(ds -> ds.getDate().equals(dto.getDate()) && 
                                     ds.getAmount().equals(dto.getAmount()) &&
                                     ds.getDemo() != null && ds.getDemo().equals(dto.getDemo()));
                    
                    if (!exists) {
                        DailySpend dailySpend = new DailySpend();
                        dailySpend.setAmount(dto.getAmount());
                        dailySpend.setDate(dto.getDate());
                        dailySpend.setDemo(dto.getDemo());
                        
                        // 设置关联对象
                        Type type = typeService.findById(dto.getTypeId())
                            .orElseThrow(() -> new RuntimeException("类型不存在: " + dto.getTypeId()));
                        User user = userService.findById(dto.getUserId())
                            .orElseThrow(() -> new RuntimeException("用户不存在: " + dto.getUserId()));
                        
                        dailySpend.setType(type);
                        dailySpend.setUser(user);
                        
                        DailySpend saved = dailySpendService.save(dailySpend);
                        syncedLocalIds.add(saved.getSpendDetailId());
                    }
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("同步数据失败: " + e.getMessage(), e);
        }
        
        // 返回远程数据的原始ID列表，用于确认同步
        return remoteIds;
    }
    
    public String confirmSync(List<Long> dailySpendIds) {
        if (dailySpendIds == null || dailySpendIds.isEmpty()) {
            return "没有需要确认同步的数据";
        }
        
        try {
            // 调用远程API确认同步完成
            String url = "http://" + SYNC_DOMAIN + "/rest/dailySpend/confirmSync";
            String result = restTemplate.postForObject(url, dailySpendIds, String.class);
            
            // 记录确认同步的详细信息
            System.out.println("确认同步完成，共 " + dailySpendIds.size() + " 条记录，远程响应: " + result);
            return "同步确认成功 - " + result;
        } catch (Exception e) {
            System.err.println("确认同步失败，数据ID: " + dailySpendIds + ", 错误: " + e.getMessage());
            throw new RuntimeException("确认同步失败: " + e.getMessage(), e);
        }
    }
}