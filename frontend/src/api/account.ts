import request from './request'

export interface Account {
  id: number
  customerId: string
  accountNo: string
  currency: string
  balance: number
  status: string
  createdAt: string
  updatedAt: string
}

export interface AccountLedger {
  id: number
  accountId: number
  transactionId: string
  direction: string
  amount: number
  balanceAfter: number
  occurredAt: string
}

// 创建账户
export function createAccount(data: { customerId: string; currency: string }) {
  return request.post<any, Account>('/account/accounts', data)
}

// 查询所有账户
export function getAllAccounts() {
  return request.get<any, Account[]>('/account/accounts')
}

// 查询账户
export function getAccount(accountId: number) {
  return request.get<any, Account>(`/account/accounts/${accountId}`)
}

// 查询账户分户账
export function getAccountLedger(accountId: number) {
  return request.get<any, AccountLedger[]>(`/account/accounts/${accountId}/ledger`)
}

// 冻结账户
export function freezeAccount(accountId: number) {
  return request.post(`/account/accounts/${accountId}/freeze`)
}

// 解冻账户
export function unfreezeAccount(accountId: number) {
  return request.post(`/account/accounts/${accountId}/unfreeze`)
}

