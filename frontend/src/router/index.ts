import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'
import Layout from '@/views/Layout.vue'

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    component: Layout,
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/Dashboard.vue'),
        meta: { title: '监控中心' }
      },
      {
        path: 'account',
        name: 'Account',
        component: () => import('@/views/Account.vue'),
        meta: { title: '账户管理' }
      },
      {
        path: 'transfer',
        name: 'Transfer',
        component: () => import('@/views/Transfer.vue'),
        meta: { title: '交易中心' }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router

