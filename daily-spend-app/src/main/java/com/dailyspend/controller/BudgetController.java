package com.dailyspend.controller;

import com.dailyspend.entity.Budget;
import com.dailyspend.service.BudgetService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/budgets")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class BudgetController {
    
    private final BudgetService budgetService;
    
    @GetMapping
    public List<Budget> getAll() {
        return budgetService.findAll();
    }
    
    @GetMapping("/type/{typeId}")
    public List<Budget> getByTypeId(@PathVariable Long typeId) {
        return budgetService.findByTypeId(typeId);
    }
    
    @GetMapping("/date-range")
    public List<Budget> getByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return budgetService.findByDateRange(startDate, endDate);
    }
    
    @PostMapping
    public Budget create(@RequestBody Budget budget) {
        return budgetService.save(budget);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Budget> update(@PathVariable Long id, @RequestBody Budget budget) {
        budget.setBudgetId(id);
        return ResponseEntity.ok(budgetService.save(budget));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        budgetService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}