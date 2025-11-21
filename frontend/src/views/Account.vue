<template>
  <div class="account-page">
    <h2 class="page-title">账户管理</h2>

    <!-- 操作按钮 -->
    <el-card style="margin-bottom: 20px;">
      <el-button type="primary" @click="showCreateDialog = true">
        <el-icon><Plus /></el-icon>
        创建账户
      </el-button>
    </el-card>

    <!-- 账户列表 -->
    <el-card>
      <template #header>
        <div class="card-header">
          <span>账户列表</span>
        </div>
      </template>
      
      <el-table :data="accounts" style="width: 100%">
        <el-table-column prop="id" label="账户ID" width="100" />
        <el-table-column prop="accountNo" label="账户号" width="200" />
        <el-table-column prop="customerId" label="客户ID" width="150" />
        <el-table-column prop="currency" label="币种" width="100" />
        <el-table-column prop="balance" label="余额" width="150">
          <template #default="scope">
            ¥{{ scope.row.balance.toLocaleString() }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="120">
          <template #default="scope">
            <el-tag :type="getStatusType(scope.row.status)">
              {{ scope.row.status }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="创建时间" width="180" />
        <el-table-column label="操作" fixed="right" width="250">
          <template #default="scope">
            <el-button size="small" @click="viewAccount(scope.row)">查看</el-button>
            <el-button size="small" type="warning" @click="freezeAccount(scope.row)" 
                       v-if="scope.row.status === 'ACTIVE'">
              冻结
            </el-button>
            <el-button size="small" type="success" @click="unfreezeAccount(scope.row)"
                       v-if="scope.row.status === 'FROZEN'">
              解冻
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 创建账户对话框 -->
    <el-dialog v-model="showCreateDialog" title="创建账户" width="500px">
      <el-form :model="createForm" label-width="100px">
        <el-form-item label="客户ID">
          <el-input v-model="createForm.customerId" placeholder="请输入客户ID" />
        </el-form-item>
        <el-form-item label="币种">
          <el-select v-model="createForm.currency" placeholder="请选择币种">
            <el-option label="人民币(CNY)" value="CNY" />
            <el-option label="美元(USD)" value="USD" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" @click="handleCreate">确定</el-button>
      </template>
    </el-dialog>

    <!-- 账户详情对话框 -->
    <el-dialog v-model="showDetailDialog" title="账户详情" width="800px">
      <el-descriptions :column="2" border v-if="currentAccount">
        <el-descriptions-item label="账户ID">{{ currentAccount.id }}</el-descriptions-item>
        <el-descriptions-item label="账户号">{{ currentAccount.accountNo }}</el-descriptions-item>
        <el-descriptions-item label="客户ID">{{ currentAccount.customerId }}</el-descriptions-item>
        <el-descriptions-item label="币种">{{ currentAccount.currency }}</el-descriptions-item>
        <el-descriptions-item label="余额">¥{{ currentAccount.balance.toLocaleString() }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="getStatusType(currentAccount.status)">{{ currentAccount.status }}</el-tag>
        </el-descriptions-item>
      </el-descriptions>
      
      <h4 style="margin-top: 20px;">分户账明细</h4>
      <el-table :data="ledgers" style="width: 100%; margin-top: 10px;" max-height="300">
        <el-table-column prop="transactionId" label="交易ID" width="150" />
        <el-table-column prop="direction" label="方向" width="100" />
        <el-table-column prop="amount" label="金额" width="120">
          <template #default="scope">
            ¥{{ scope.row.amount.toLocaleString() }}
          </template>
        </el-table-column>
        <el-table-column prop="balanceAfter" label="交易后余额" width="150">
          <template #default="scope">
            ¥{{ scope.row.balanceAfter.toLocaleString() }}
          </template>
        </el-table-column>
        <el-table-column prop="occurredAt" label="发生时间" />
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import * as accountApi from '@/api/account'

const accounts = ref<accountApi.Account[]>([])
const ledgers = ref<accountApi.AccountLedger[]>([])
const showCreateDialog = ref(false)
const showDetailDialog = ref(false)
const currentAccount = ref<accountApi.Account | null>(null)

const createForm = ref({
  customerId: '',
  currency: 'CNY'
})

onMounted(() => {
  loadAccounts()
})

const loadAccounts = async () => {
  try {
    // 加载所有账户
    accounts.value = await accountApi.getAllAccounts()
  } catch (error) {
    console.error('加载账户失败:', error)
    ElMessage.error('加载账户列表失败')
  }
}

const handleCreate = async () => {
  try {
    await accountApi.createAccount(createForm.value)
    ElMessage.success('创建成功')
    showCreateDialog.value = false
    loadAccounts()
  } catch (error) {
    ElMessage.error('创建失败')
  }
}

const viewAccount = async (account: accountApi.Account) => {
  currentAccount.value = account
  try {
    ledgers.value = await accountApi.getAccountLedger(account.id)
    showDetailDialog.value = true
  } catch (error) {
    ElMessage.error('加载账户详情失败')
  }
}

const freezeAccount = async (account: accountApi.Account) => {
  try {
    await ElMessageBox.confirm('确定要冻结该账户吗?', '提示', { type: 'warning' })
    await accountApi.freezeAccount(account.id)
    ElMessage.success('冻结成功')
    loadAccounts()
  } catch (error) {
    // 用户取消
  }
}

const unfreezeAccount = async (account: accountApi.Account) => {
  try {
    await accountApi.unfreezeAccount(account.id)
    ElMessage.success('解冻成功')
    loadAccounts()
  } catch (error) {
    ElMessage.error('解冻失败')
  }
}

const getStatusType = (status: string) => {
  const map: Record<string, any> = {
    'ACTIVE': 'success',
    'FROZEN': 'warning',
    'CLOSED': 'info'
  }
  return map[status] || 'info'
}
</script>

<style scoped>
.account-page {
  padding: 20px;
}

.page-title {
  margin-bottom: 20px;
  color: #303133;
}
</style>

