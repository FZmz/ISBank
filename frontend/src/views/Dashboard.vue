<template>
  <div class="dashboard">
    <h2 class="page-title">业务监控仪表盘</h2>
    
    <!-- KPI指标卡片 -->
    <el-row :gutter="20" class="kpi-cards">
      <el-col :span="6">
        <el-card class="kpi-card">
          <div class="kpi-content">
            <el-icon :size="40" color="#409EFF"><TrendCharts /></el-icon>
            <div class="kpi-info">
              <div class="kpi-label">今日交易笔数</div>
              <div class="kpi-value">{{ stats.todayTransactions }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="kpi-card">
          <div class="kpi-content">
            <el-icon :size="40" color="#67C23A"><Money /></el-icon>
            <div class="kpi-info">
              <div class="kpi-label">今日交易金额</div>
              <div class="kpi-value">¥{{ stats.todayAmount.toLocaleString() }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="kpi-card">
          <div class="kpi-content">
            <el-icon :size="40" color="#E6A23C"><SuccessFilled /></el-icon>
            <div class="kpi-info">
              <div class="kpi-label">交易成功率</div>
              <div class="kpi-value">{{ stats.successRate }}%</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card class="kpi-card">
          <div class="kpi-content">
            <el-icon :size="40" color="#F56C6C"><Timer /></el-icon>
            <div class="kpi-info">
              <div class="kpi-label">平均响应时延</div>
              <div class="kpi-value">{{ stats.avgResponseTime }}ms</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 系统状态 -->
    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="24">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>系统服务状态</span>
            </div>
          </template>
          <el-row :gutter="20">
            <el-col :span="4" v-for="service in services" :key="service.name">
              <div class="service-status">
                <el-tag :type="service.status === 'UP' ? 'success' : 'danger'">
                  {{ service.status }}
                </el-tag>
                <div class="service-name">{{ service.name }}</div>
              </div>
            </el-col>
          </el-row>
        </el-card>
      </el-col>
    </el-row>

    <!-- 快速访问 -->
    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="24">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>快速访问</span>
            </div>
          </template>
          <div class="quick-actions">
            <el-button type="primary" @click="$router.push('/account')">
              <el-icon><User /></el-icon>
              账户管理
            </el-button>
            <el-button type="success" @click="$router.push('/transfer')">
              <el-icon><Promotion /></el-icon>
              发起转账
            </el-button>
            <el-button type="info" @click="openApiDoc">
              <el-icon><Document /></el-icon>
              API文档
            </el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { TrendCharts, Money, SuccessFilled, Timer, User, Promotion, Document } from '@element-plus/icons-vue'

const stats = ref({
  todayTransactions: 0,
  todayAmount: 0,
  successRate: 100,
  avgResponseTime: 0
})

const services = ref([
  { name: 'Eureka Server', status: 'UP' },
  { name: 'Account Service', status: 'UP' },
  { name: 'Transfer Service', status: 'UP' },
  { name: 'Risk Service', status: 'UP' },
  { name: 'Ledger Service', status: 'UP' },
  { name: 'Notification Service', status: 'UP' }
])

const openApiDoc = () => {
  window.open('http://localhost:8080/doc.html', '_blank')
}
</script>

<style scoped>
.dashboard {
  padding: 20px;
}

.page-title {
  margin-bottom: 20px;
  color: #303133;
}

.kpi-card {
  cursor: pointer;
  transition: all 0.3s;
}

.kpi-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.kpi-content {
  display: flex;
  align-items: center;
  gap: 20px;
}

.kpi-info {
  flex: 1;
}

.kpi-label {
  font-size: 14px;
  color: #909399;
  margin-bottom: 8px;
}

.kpi-value {
  font-size: 24px;
  font-weight: bold;
  color: #303133;
}

.service-status {
  text-align: center;
  padding: 10px;
}

.service-name {
  margin-top: 8px;
  font-size: 14px;
  color: #606266;
}

.quick-actions {
  display: flex;
  gap: 15px;
}
</style>

