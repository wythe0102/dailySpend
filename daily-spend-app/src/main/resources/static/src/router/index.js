import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    redirect: '/daily-spends'
  },
  {
    path: '/daily-spends',
    name: 'DailySpends',
    component: () => import('../views/DailySpendList.vue')
  },
  {
    path: '/daily-spends/summary',
    name: 'DailySpendSummary',
    component: () => import('../views/DailySpendSummary.vue')
  },
  {
    path: '/daily-weights',
    name: 'DailyWeights',
    component: () => import('../views/DailyWeightList.vue')
  },
  {
    path: '/budgets',
    name: 'Budgets',
    component: () => import('../views/BudgetList.vue')
  },
  {
    path: '/types',
    name: 'Types',
    component: () => import('../views/TypeList.vue')
  },
  {
    path: '/reports/month',
    name: 'MonthReport',
    component: () => import('../views/MonthReport.vue')
  },
  {
    path: '/reports/year',
    name: 'YearReport',
    component: () => import('../views/YearReport.vue')
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router