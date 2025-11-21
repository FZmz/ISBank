<template>
  <el-container class="layout-container">
    <!-- 顶部导航栏 -->
    <el-header class="header">
      <div class="header-left">
        <el-icon :size="28" color="#409EFF"><Money /></el-icon>
        <span class="logo-text">ISBank 韧性银行系统</span>
      </div>
      <el-menu
        :default-active="activeMenu"
        class="header-menu"
        mode="horizontal"
        @select="handleMenuSelect"
      >
        <el-menu-item index="/dashboard">
          <el-icon><Monitor /></el-icon>
          <span>监控中心</span>
        </el-menu-item>
        <el-menu-item index="/account">
          <el-icon><User /></el-icon>
          <span>账户管理</span>
        </el-menu-item>
        <el-menu-item index="/transfer">
          <el-icon><Promotion /></el-icon>
          <span>交易中心</span>
        </el-menu-item>
      </el-menu>
      <div class="header-right">
        <el-badge :value="0" class="item">
          <el-icon :size="20"><Bell /></el-icon>
        </el-badge>
      </div>
    </el-header>

    <!-- 主内容区 -->
    <el-main class="main-content">
      <router-view />
    </el-main>
  </el-container>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { Money, Monitor, User, Promotion, Bell } from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()
const activeMenu = ref(route.path)

watch(() => route.path, (newPath) => {
  activeMenu.value = newPath
})

const handleMenuSelect = (index: string) => {
  router.push(index)
}
</script>

<style scoped>
.layout-container {
  height: 100vh;
}

.header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
  color: white;
  padding: 0 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo-text {
  font-size: 20px;
  font-weight: bold;
  color: white;
}

.header-menu {
  flex: 1;
  background: transparent;
  border: none;
  margin-left: 40px;
}

.header-menu :deep(.el-menu-item) {
  color: rgba(255, 255, 255, 0.8);
  border-bottom: 2px solid transparent;
}

.header-menu :deep(.el-menu-item:hover),
.header-menu :deep(.el-menu-item.is-active) {
  color: white;
  background: rgba(255, 255, 255, 0.1);
  border-bottom-color: white;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 20px;
  color: white;
}

.main-content {
  padding: 20px;
  background-color: #f0f2f5;
  overflow-y: auto;
}
</style>

