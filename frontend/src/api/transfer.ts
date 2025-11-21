import request from './request'

export interface Transfer {
  id: number
  fromAccountId: number
  toAccountId: number
  amount: number
  currency: string
  type: string
  status: string
  createdAt: string
  lastUpdatedAt: string
}

// 发起转账
export function createTransfer(data: {
  fromAccountId: number
  toAccountId: number
  amount: number
  currency: string
  type: string
}) {
  return request.post<any, Transfer>('/transfer/transfers', data)
}

// 查询转账
export function getTransfer(transferId: number) {
  return request.get<any, Transfer>(`/transfer/transfers/${transferId}`)
}

