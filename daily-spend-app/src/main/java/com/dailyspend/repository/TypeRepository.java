package com.dailyspend.repository;

import com.dailyspend.entity.Type;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TypeRepository extends JpaRepository<Type, Long> {
    List<Type> findByParentIsNull();
    List<Type> findByParent_TypeId(Long parentId);
}