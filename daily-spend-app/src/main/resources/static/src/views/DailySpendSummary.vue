<template>
  <div class="daily-spend-summary">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>日常记账汇总</span>
        </div>
      </template>
      
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="日期范围">
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            @change="handleSearch"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
      
      <el-row :gutter="20" class="summary-cards">
        <el-col :span="8">
          <el-card class="summary-card">
            <div class="card-content">
              <div class="card-title">总支出</div>
              <div class="card-value">¥{{ summary.totalExpense }}</div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card class="summary-card">
            <div class="card-content">
              <div class="card-title">总收入</div>
              <div class="card-value">¥{{ summary.totalIncome }}</div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="8">
          <el-card class="summary-card">
            <div class="card-content">
              <div class="card-title">净收入</div>
              <div class="card-value" :class="{ 'text-success': summary.netIncome >= 0, 'text-danger': summary.netIncome < 0 }">
                ¥{{ summary.netIncome }}
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
      
      <el-row :gutter="20" class="charts">
        <el-col :span="12">
          <el-card>
            <template #header>
              <span>支出分类统计</span>
            </template>
            <div id="expense-chart" style="height: 300px;"></div>
          </el-card>
        </el-col>
        <el-col :span="12">
          <el-card>
            <template #header>
              <span>收入分类统计</span>
            </template>
            <div id="income-chart" style="height: 300px;"></div>
          </el-card>
        </el-col>
      </el-row>
      
      <el-table :data="tableData" style="width: 100%">
        <el-table-column prop="type" label="类别" />
        <el-table-column prop="totalAmount" label="总金额">
          <template #default="{ row }">
            ¥{{ row.totalAmount }}
          </template>
        </el-table-column>
        <el-table-column prop="count" label="笔数" />
        <el-table-column prop="percentage" label="占比">
          <template #default="{ row }">
            {{ row.percentage }}%
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { dailySpendApi } from '../api'
import * as echarts from 'echarts'

const tableData = ref([])
const summary = reactive({
  totalExpense: 0,
  totalIncome: 0,
  netIncome: 0
})

const searchForm = reactive({
  userId: 1 // 默认用户ID
})

const dateRange = ref([])

let expenseChart = null
let incomeChart = null

const loadData = async () => {
  try {
    const startDate = dateRange.value?.[0] || new Date(new Date().getFullYear(), new Date().getMonth(), 1)
    const endDate = dateRange.value?.[1] || new Date()
    
    const response = await dailySpendApi.getByUserIdAndDateRange(
      searchForm.userId,
      startDate.toISOString().split('T')[0],
      endDate.toISOString().split('T')[0]
    )
    
    const data = response.data
    processData(data)
  } catch (error) {
    ElMessage.error('加载数据失败')
  }
}

const processData = (data) => {
  const expenseData = data.filter(item => item.type.type === 'EXPENSE')
  const incomeData = data.filter(item => item.type.type === 'INCOME')
  
  // 计算汇总数据
  summary.totalExpense = expenseData.reduce((sum, item) => sum + item.amount, 0)
  summary.totalIncome = incomeData.reduce((sum, item) => sum + item.amount, 0)
  summary.netIncome = summary.totalIncome - summary.totalExpense
  
  // 按类别分组
  const expenseByType = groupByType(expenseData)
  const incomeByType = groupByType(incomeData)
  
  // 更新表格数据
  tableData.value = [
    ...expenseByType.map(item => ({ ...item, type: `${item.type} (支出)` })),
    ...incomeByType.map(item => ({ ...item, type: `${item.type} (收入)` }))
  ]
  
  // 更新图表
  updateCharts(expenseByType, incomeByType)
}

const groupByType = (data) => {
  const groups = {}
  data.forEach(item => {
    if (!groups[item.type.name]) {
      groups[item.type.name] = {
        type: item.type.name,
        totalAmount: 0,
        count: 0
      }
    }
    groups[item.type.name].totalAmount += item.amount
    groups[item.type.name].count += 1
  })
  
  const total = Object.values(groups).reduce((sum, item) => sum + item.totalAmount, 0)
  return Object.values(groups).map(item => ({
    ...item,
    percentage: total > 0 ? ((item.totalAmount / total) * 100).toFixed(2) : 0
  }))
}

const updateCharts = (expenseData, incomeData) => {
  // 支出饼图
  if (expenseChart) {
    expenseChart.dispose()
  }
  expenseChart = echarts.init(document.getElementById('expense-chart'))
  expenseChart.setOption({
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b}: ¥{c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      left: 'left'
    },
    series: [
      {
        name: '支出',
        type: 'pie',
        radius: '50%',
        data: expenseData.map(item => ({
          name: item.type,
          value: item.totalAmount
        })),
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        }
      }
    ]
  })
  
  // 收入饼图
  if (incomeChart) {
    incomeChart.dispose()
  }
  incomeChart = echarts.init(document.getElementById('income-chart'))
  incomeChart.setOption({
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b}: ¥{c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      left: 'left'
    },
    series: [
      {
        name: '收入',
        type: 'pie',
        radius: '50%',
        data: incomeData.map(item => ({
          name: item.type,
          value: item.totalAmount
        })),
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        }
      }
    ]
  })
}

const handleSearch = () => {
  loadData()
}

const handleReset = () => {
  dateRange.value = []
  loadData()
}

onMounted(() => {
  loadData()
})

onMounted(() => {
  window.addEventListener('resize', () => {
    if (expenseChart) expenseChart.resize()
    if (incomeChart) incomeChart.resize()
  })
})
</script>

<style scoped>
.daily-spend-summary {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-form {
  margin-bottom: 20px;
}

.summary-cards {
  margin-bottom: 20px;
}

.summary-card {
  text-align: center;
}

.card-title {
  font-size: 14px;
  color: #909399;
  margin-bottom: 10px;
}

.card-value {
  font-size: 24px;
  font-weight: bold;
}

.text-success {
  color: #67c23a;
}

.text-danger {
  color: #ff4949;
}

.charts {
  margin-bottom: 20px;
}
</style>