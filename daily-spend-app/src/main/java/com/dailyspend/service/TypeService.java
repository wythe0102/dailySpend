package com.dailyspend.service;

import com.dailyspend.entity.Type;
import com.dailyspend.repository.TypeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TypeService {
    
    private final TypeRepository typeRepository;
    
    public List<Type> findAll() {
        return typeRepository.findAll();
    }
    
    public List<Type> findRootTypes() {
        return typeRepository.findByParentIsNull();
    }
    
    public List<Type> findByParentId(Long parentId) {
        return typeRepository.findByParent_TypeId(parentId);
    }
    
    public Type save(Type type) {
        return typeRepository.save(type);
    }
    
    public void deleteById(Long id) {
        typeRepository.deleteById(id);
    }
}