package com.dailyspend.controller;

import com.dailyspend.entity.Type;
import com.dailyspend.service.TypeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/types")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class TypeController {
    
    private final TypeService typeService;
    
    @GetMapping
    public List<Type> getAll() {
        return typeService.findAll();
    }
    
    @GetMapping("/root")
    public List<Type> getRootTypes() {
        return typeService.findRootTypes();
    }
    
    @GetMapping("/parent/{parentId}")
    public List<Type> getByParentId(@PathVariable Long parentId) {
        return typeService.findByParentId(parentId);
    }
    
    @PostMapping
    public Type create(@RequestBody Type type) {
        return typeService.save(type);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Type> update(@PathVariable Long id, @RequestBody Type type) {
        type.setTypeId(id);
        return ResponseEntity.ok(typeService.save(type));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        typeService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}