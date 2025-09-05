<template>
  <div id="app">
    <el-container class="layout-container">
      <el-header class="header">
        <div class="header-content">
          <h1>龙珊记账系统</h1>
        </div>
      </el-header>
      
      <el-container>
        <el-aside width="200px" class="aside">
          <el-menu
            :default-active="$route.path"
            router
            class="menu"
            background-color="#545c64"
            text-color="#fff"
            active-text-color="#ffd04b"
          >
            <el-menu-item index="/daily-spends">
              <el-icon><Money /></el-icon>
              <span>日常记账</span>
            </el-menu-item>
            <el-menu-item index="/daily-spends/summary">
              <el-icon><Document /></el-icon>
              <span>记账汇总</span>
            </el-menu-item>
            <el-menu-item index="/daily-weights">
              <el-icon><User /></el-icon>
              <span>体重记录</span>
            </el-menu-item>
            <el-menu-item index="/budgets">
              <el-icon><Wallet /></el-icon>
              <span>预算管理</span>
            </el-menu-item>
            <el-menu-item index="/types">
              <el-icon><Collection /></el-icon>
              <span>类别维护</span>
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
  justify-content: center;
}

.header-content h1 {
  margin: 0;
  font-size: 24px;
}

.aside {
  background-color: #545c64;
}

.menu {
  border-right: none;
}

.main {
  background-color: #f5f5f5;
  padding: 20px;
}
</style>