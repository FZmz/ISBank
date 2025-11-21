<template>
  <div class="transfer-page">
    <h2 class="page-title">交易中心</h2>

    <el-row :gutter="20">
      <!-- 转账表单 -->
      <el-col :span="12">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>发起转账</span>
            </div>
          </template>
          
          <el-form :model="transferForm" label-width="120px">
            <el-form-item label="源账户">
              <el-select v-model="transferForm.fromAccountId" placeholder="请选择源账户" style="width: 100%;">
                <el-option
                  v-for="account in accounts"
                  :key="account.id"
                  :label="`${account.accountNo} (余额: ¥${account.balance.toLocaleString()})`"
                  :value="account.id"
                >
                  <div style="display: flex; justify-content: space-between;">
                    <span>{{ account.accountNo }}</span>
                    <span style="color: #8492a6; font-size: 13px;">
                      余额: ¥{{ account.balance.toLocaleString() }}
                    </span>
                  </div>
                </el-option>
              </el-select>
            </el-form-item>
            <el-form-item label="目标账户">
              <el-select v-model="transferForm.toAccountId" placeholder="请选择目标账户" style="width: 100%;">
                <el-option
                  v-for="account in accounts"
                  :key="account.id"
                  :label="`${account.accountNo} (余额: ¥${account.balance.toLocaleString()})`"
                  :value="account.id"
                  :disabled="account.id === transferForm.fromAccountId"
                >
                  <div style="display: flex; justify-content: space-between;">
                    <span>{{ account.accountNo }}</span>
                    <span style="color: #8492a6; font-size: 13px;">
                      余额: ¥{{ account.balance.toLocaleString() }}
                    </span>
                  </div>
                </el-option>
              </el-select>
            </el-form-item>
            <el-form-item label="转账金额">
              <el-input-number v-model="transferForm.amount" :min="0.01" :precision="2" style="width: 100%;" />
            </el-form-item>
            <el-form-item label="币种">
              <el-select v-model="transferForm.currency" style="width: 100%;">
                <el-option label="人民币(CNY)" value="CNY" />
                <el-option label="美元(USD)" value="USD" />
              </el-select>
            </el-form-item>
            <el-form-item label="转账类型">
              <el-select v-model="transferForm.type" style="width: 100%;">
                <el-option label="行内转账" value="INTERNAL" />
                <el-option label="跨行转账" value="EXTERNAL" />
              </el-select>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleTransfer" :loading="loading">
                <el-icon><Promotion /></el-icon>
                提交转账
              </el-button>
              <el-button @click="resetForm">重置</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-col>

      <!-- 转账结果 -->
      <el-col :span="12">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>转账结果</span>
            </div>
          </template>
          
          <div v-if="transferResult" class="transfer-result">
            <el-result
              :icon="getResultIcon(transferResult.status)"
              :title="getResultTitle(transferResult.status)"
            >
              <template #sub-title>
                <div class="result-details">
                  <p><strong>转账ID:</strong> {{ transferResult.id }}</p>
                  <p><strong>源账户:</strong> {{ transferResult.fromAccountId }}</p>
                  <p><strong>目标账户:</strong> {{ transferResult.toAccountId }}</p>
                  <p><strong>金额:</strong> ¥{{ transferResult.amount.toLocaleString() }}</p>
                  <p><strong>状态:</strong> 
                    <el-tag :type="getStatusType(transferResult.status)">
                      {{ transferResult.status }}
                    </el-tag>
                  </p>
                  <p><strong>创建时间:</strong> {{ transferResult.createdAt }}</p>
                </div>
              </template>
              <template #extra>
                <el-button type="primary" @click="queryTransfer">刷新状态</el-button>
              </template>
            </el-result>
          </div>
          <el-empty v-else description="暂无转账记录" />
        </el-card>
      </el-col>
    </el-row>

    <!-- 转账进度 -->
    <el-row :gutter="20" style="margin-top: 20px;" v-if="transferResult">
      <el-col :span="24">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>转账流程</span>
            </div>
          </template>
          
          <el-steps :active="getStepActive(transferResult.status)" finish-status="success">
            <el-step title="初始化" description="INIT" />
            <el-step title="风控检查" description="RISK_CHECKING" />
            <el-step title="风控通过" description="RISK_PASSED" />
            <el-step title="扣款完成" description="DEBIT_DONE" />
            <el-step title="入账完成" description="CREDIT_DONE" />
            <el-step title="总账记账" description="LEDGER_POSTED" />
            <el-step title="转账成功" description="SUCCESS" />
          </el-steps>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Promotion } from '@element-plus/icons-vue'
import * as transferApi from '@/api/transfer'
import * as accountApi from '@/api/account'

const loading = ref(false)
const transferResult = ref<transferApi.Transfer | null>(null)
const accounts = ref<accountApi.Account[]>([])

const transferForm = ref({
  fromAccountId: null as number | null,
  toAccountId: null as number | null,
  amount: 100,
  currency: 'CNY',
  type: 'INTERNAL'
})

// 加载账户列表
const loadAccounts = async () => {
  try {
    accounts.value = await accountApi.getAllAccounts()
    // 如果有账户，设置默认值
    if (accounts.value.length >= 2) {
      transferForm.value.fromAccountId = accounts.value[0].id
      transferForm.value.toAccountId = accounts.value[1].id
    }
  } catch (error) {
    console.error('加载账户列表失败:', error)
    ElMessage.error('加载账户列表失败')
  }
}

// 组件挂载时加载账户
onMounted(() => {
  loadAccounts()
})

const handleTransfer = async () => {
  // 表单验证
  if (!transferForm.value.fromAccountId) {
    ElMessage.warning('请选择源账户')
    return
  }
  if (!transferForm.value.toAccountId) {
    ElMessage.warning('请选择目标账户')
    return
  }
  if (transferForm.value.fromAccountId === transferForm.value.toAccountId) {
    ElMessage.warning('源账户和目标账户不能相同')
    return
  }
  if (!transferForm.value.amount || transferForm.value.amount <= 0) {
    ElMessage.warning('请输入有效的转账金额')
    return
  }

  loading.value = true
  try {
    const result = await transferApi.createTransfer({
      fromAccountId: transferForm.value.fromAccountId,
      toAccountId: transferForm.value.toAccountId,
      amount: transferForm.value.amount,
      currency: transferForm.value.currency,
      type: transferForm.value.type
    })
    transferResult.value = result
    ElMessage.success('转账提交成功')
    // 刷新账户列表
    await loadAccounts()
  } catch (error: any) {
    ElMessage.error(error.message || '转账失败')
  } finally {
    loading.value = false
  }
}

const queryTransfer = async () => {
  if (!transferResult.value) return
  try {
    const result = await transferApi.getTransfer(transferResult.value.id)
    transferResult.value = result
    ElMessage.success('状态已刷新')
  } catch (error) {
    ElMessage.error('查询失败')
  }
}

const resetForm = () => {
  transferForm.value = {
    fromAccountId: accounts.value.length >= 1 ? accounts.value[0].id : null,
    toAccountId: accounts.value.length >= 2 ? accounts.value[1].id : null,
    amount: 100,
    currency: 'CNY',
    type: 'INTERNAL'
  }
  transferResult.value = null
}

const getResultIcon = (status: string) => {
  return status === 'SUCCESS' ? 'success' : status === 'FAILED' ? 'error' : 'info'
}

const getResultTitle = (status: string) => {
  const map: Record<string, string> = {
    'SUCCESS': '转账成功',
    'FAILED': '转账失败',
    'INIT': '转账初始化',
    'PENDING': '转账处理中'
  }
  return map[status] || '转账处理中'
}

const getStatusType = (status: string) => {
  const map: Record<string, any> = {
    'SUCCESS': 'success',
    'FAILED': 'danger',
    'INIT': 'info'
  }
  return map[status] || 'warning'
}

const getStepActive = (status: string) => {
  const steps = ['INIT', 'RISK_CHECKING', 'RISK_PASSED', 'DEBIT_DONE', 'CREDIT_DONE', 'LEDGER_POSTED', 'SUCCESS']
  const index = steps.indexOf(status)
  return index >= 0 ? index + 1 : 0
}
</script>

<style scoped>
.transfer-page {
  padding: 20px;
}

.page-title {
  margin-bottom: 20px;
  color: #303133;
}

.transfer-result {
  padding: 20px;
}

.result-details {
  text-align: left;
  margin-top: 20px;
}

.result-details p {
  margin: 10px 0;
  font-size: 14px;
}
</style>

