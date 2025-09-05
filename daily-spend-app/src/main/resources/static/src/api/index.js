import axios from 'axios'

const api = axios.create({
  baseURL: '/api',
  timeout: 10000
})

// 日常记账API
export const dailySpendApi = {
  getAll: () => api.get('/daily-spends'),
  getByUserId: (userId) => api.get(`/daily-spends/user/${userId}`),
  getPage: (params) => api.get('/daily-spends/page', { params }),
  getByUserIdAndDateRange: (userId, startDate, endDate) => 
    api.get(`/daily-spends/user/${userId}/date-range`, { params: { startDate, endDate } }),
  getTotalByUserAndDateRange: (userId, startDate, endDate) => 
    api.get(`/daily-spends/total/user/${userId}/date-range`, { params: { startDate, endDate } }),
  create: (data) => api.post('/daily-spends', data),
  update: (id, data) => api.put(`/daily-spends/${id}`, data),
  delete: (id) => api.delete(`/daily-spends/${id}`)
}

// 类别API
export const typeApi = {
  getAll: () => api.get('/types'),
  getRootTypes: () => api.get('/types/root'),
  getByParentId: (parentId) => api.get(`/types/parent/${parentId}`),
  create: (data) => api.post('/types', data),
  update: (id, data) => api.put(`/types/${id}`, data),
  delete: (id) => api.delete(`/types/${id}`)
}

// 体重API
export const dailyWeightApi = {
  getAll: () => api.get('/daily-weights'),
  getByUserId: (userId) => api.get(`/daily-weights/user/${userId}`),
  getByUserIdAndTimeRange: (userId, startTime, endTime) => 
    api.get(`/daily-weights/user/${userId}/time-range`, { params: { startTime, endTime } }),
  create: (data) => api.post('/daily-weights', data),
  update: (id, data) => api.put(`/daily-weights/${id}`, data),
  delete: (id) => api.delete(`/daily-weights/${id}`)
}

// 预算API
export const budgetApi = {
  getAll: () => api.get('/budgets'),
  getByTypeId: (typeId) => api.get(`/budgets/type/${typeId}`),
  getByDateRange: (startDate, endDate) => 
    api.get('/budgets/date-range', { params: { startDate, endDate } }),
  create: (data) => api.post('/budgets', data),
  update: (id, data) => api.put(`/budgets/${id}`, data),
  delete: (id) => api.delete(`/budgets/${id}`)
}