<template>
  <div id="app">
    <el-container class="layout-container">
      <el-header class="header">
        <div class="header-content">
          <div class="header-left">
            <el-button 
              type="primary" 
              class="collapse-btn" 
              @click="toggleCollapse"
              circle
              :title="isCollapse ? '展开菜单' : '收起菜单'"
            >
              <el-icon size="20">
                <Fold v-if="!isCollapse" />
                <Expand v-if="isCollapse" />
              </el-icon>
            </el-button>
          </div>
          <div class="header-center">
            <h1>龙珊记账系统</h1>
          </div>
          <div class="header-right"></div>
        </div>
      </el-header>
      
      <el-container>
        <el-aside 
          :width="isCollapse ? '64px' : '200px'" 
          class="aside"
          :class="{ 'collapsed': isCollapse }"
        >
          <el-menu
            :default-active="$route.path"
            router
            class="menu"
            :collapse="isCollapse"
            background-color="#545c64"
            text-color="#fff"
            active-text-color="#ffd04b"
            style="height: 100%; border-right: none;"
          >
            <el-menu-item index="/daily-spends">
              <el-icon><Money /></el-icon>
              <template #title>日常记账</template>
            </el-menu-item>
            <el-menu-item index="/daily-spends/summary">
              <el-icon><Document /></el-icon>
              <template #title>记账汇总</template>
            </el-menu-item>
            <el-menu-item index="/daily-weights">
              <el-icon><User /></el-icon>
              <template #title>体重记录</template>
            </el-menu-item>
            <el-menu-item index="/types">
              <el-icon><Collection /></el-icon>
              <template #title>类别维护</template>
            </el-menu-item>
            <el-sub-menu index="/reports">
              <template #title>
                <el-icon><PieChart /></el-icon>
                <span>报表</span>
              </template>
              <el-menu-item index="/reports/month">月报表</el-menu-item>
              <el-menu-item index="/reports/year">年报表</el-menu-item>
            </el-sub-menu>
          </el-menu>
        </el-aside>
        
        <el-main class="main">
          <router-view />
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Money, Document, User, Wallet, Collection, PieChart, Fold, Expand } from '@element-plus/icons-vue'

const isCollapse = ref(false)

const toggleCollapse = () => {
  isCollapse.value = !isCollapse.value
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  height: 100vh;
}

.layout-container {
  height: 100vh;
}

.header {
  background-color: #409EFF;
  color: white;
  display: flex;
  align-items: center;
  height: 50px !important;
  line-height: 50px;
  padding: 0 20px;
}

.header-content {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.header-left {
  display: flex;
  align-items: center;
  flex: 1;
}

.header-center {
  display: flex;
  align-items: center;
  justify-content: center;
  flex: 1;
}

.header-right {
  flex: 1;
}

.collapse-btn {
  background-color: rgba(255, 255, 255, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.3);
  color: white;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
}

.collapse-btn:hover {
  background-color: rgba(255, 255, 255, 0.3);
  transform: scale(1.1);
  border-color: rgba(255, 255, 255, 0.5);
}

.header-content h1 {
  margin: 0;
  font-size: 20px;
  font-weight: 500;
}

.aside {
  background-color: #545c64;
  transition: width 0.3s ease;
  overflow: hidden;
  height: calc(100vh - 50px);
}

.aside.collapsed {
  width: 64px;
}

.menu {
  border-right: none;
  transition: all 0.3s ease;
  overflow-y: auto;
  overflow-x: hidden;
}

.menu::-webkit-scrollbar {
  width: 0px;
  background: transparent;
}

.main {
  background-color: #f5f5f5;
  padding: 20px;
  transition: margin-left 0.3s ease;
}

/* 响应式设计 */
@media screen and (max-width: 768px) {
  .header {
    height: 45px !important;
    line-height: 45px;
    padding: 0 15px;
  }
  
  .header-content h1 {
    font-size: 18px;
  }
  
  .collapse-btn {
    font-size: 16px;
  }
}
</style>