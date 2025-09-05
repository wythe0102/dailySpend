<template>
  <div class="month-report">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>月度报表</span>
        </div>
      </template>
      
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="选择月份">
          <el-date-picker
            v-model="searchForm.month"
            type="month"
            placeholder="选择月份"
            @change="handleSearch"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
        </el-form-item>
      </el-form>
      
      <el-row :gutter="20" class="summary-cards">
        <el-col :span="6">
          <el-card class="summary-card">
            <div class="card-content">
              <div class="card-title">总支出</div>
              <div class="card-value">¥{{ summary.totalExpense }}</div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="summary-card">
            <div class="card-content">
              <div class="card-title">总收入</div>
              <div class="card-value">¥{{ summary.totalIncome }}</div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="summary-card">
            <div class="card-content">
              <div class="card-title">净收入</div>
              <div class="card-value" :class="{ 'text-success': summary.netIncome >= 0, 'text-danger': summary.netIncome < 0 }">
                ¥{{ summary.netIncome }}
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="summary-card">
            <div class="card-content">
              <div class="card-title">日均支出</div>
              <div class="card-value">¥{{ summary.dailyExpense }}</div>
            </div>
          </el-card>
        </el-col>
      </el-row>
      
      <el-row :gutter="20" class="charts">
        <el-col :span="12">
          <el-card>
            <template #header>
              <span>每日支出趋势</span>
            </template>
            <div id="daily-expense-chart" style="height: 300px;"></div>
          </el-card>
        </el-col>
        <el-col :span="12">
          <el-card>
            <template #header>
              <span>类别支出占比</span>
            </template>
            <div id="category-chart" style="height: 300px;"></div>
          </el-card>
        </el-col>
      </el-row>
      
      <el-table :data="tableData" style="width: 100%">
        <el-table-column prop="date" label="日期" />
        <el-table-column prop="type" label="类别" />
        <el-table-column prop="amount" label="金额">
          <template #default="{ row }">
            <span :class="{ 'text-danger': row.amount < 0, 'text-success': row.amount >= 0 }">
              ¥{{ Math.abs(row.amount) }}
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="demo" label="备注" />
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
  netIncome: 0,
  dailyExpense: 0
})

const searchForm = reactive({
  userId: 1, // 默认用户ID
  month: new Date()
})

let dailyExpenseChart = null
let categoryChart = null

const loadData = async () => {
  try {
    const year = searchForm.month.getFullYear()
    const month = searchForm.month.getMonth()
    const startDate = new Date(year, month, 1)
    const endDate = new Date(year, month + 1, 0)
    
    const response = await dailySpendApi.getByUserIdAndDateRange(
      searchForm.userId,
      startDate.toISOString().split('T')[0],
      endDate.toISOString().split('T')[0]
    )
    
    const data = response.data
    processData(data, startDate, endDate)
  } catch (error) {
    ElMessage.error('加载数据失败')
  }
}

const processData = (data, startDate, endDate) => {
  const daysInMonth = endDate.getDate()
  const dailyData = Array(daysInMonth).fill(0)
  
  // 计算汇总数据
  const expenseData = data.filter(item => item.type.type === 'EXPENSE')
  const incomeData = data.filter(item => item.type.type === 'INCOME')
  
  summary.totalExpense = expenseData.reduce((sum, item) => sum + item.amount, 0)
  summary.totalIncome = incomeData.reduce((sum, item) => sum + item.amount, 0)
  summary.netIncome = summary.totalIncome - summary.totalExpense
  summary.dailyExpense = (summary.totalExpense / daysInMonth).toFixed(2)
  
  // 计算每日支出
  expenseData.forEach(item => {
    const date = new Date(item.date)
    const day = date.getDate() - 1
    dailyData[day] += item.amount
  })
  
  // 更新表格数据
  tableData.value = data.map(item => ({
    ...item,
    type: item.type.name,
    amount: item.type.type === 'EXPENSE' ? -item.amount : item.amount
  }))
  
  // 更新图表
  updateCharts(dailyData, expenseData)
}

const updateCharts = (dailyData, expenseData) => {
  // 每日支出趋势图
  if (dailyExpenseChart) {
    dailyExpenseChart.dispose()
  }
  dailyExpenseChart = echarts.init(document.getElementById('daily-expense-chart'))
  dailyExpenseChart.setOption({
    tooltip: {
      trigger: 'axis'
    },
    xAxis: {
      type: 'category',
      data: Array.from({ length: dailyData.length }, (_, i) => `${i + 1}日`)
    },
    yAxis: {
      type: 'value',
      name: '金额'
    },
    series: [
      {
        name: '支出',
        type: 'line',
        data: dailyData,
        smooth: true,
        areaStyle: {}
      }
    ]
  })
  
  // 类别支出占比图
  if (categoryChart) {
    categoryChart.dispose()
  }
  categoryChart = echarts.init(document.getElementById('category-chart'))
  
  const categoryData = {}
  expenseData.forEach(item => {
    if (!categoryData[item.type.name]) {
      categoryData[item.type.name] = 0
    }
    categoryData[item.type.name] += item.amount
  })
  
  categoryChart.setOption({
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
        data: Object.entries(categoryData).map(([name, value]) => ({
          name,
          value
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
  searchForm.month = new Date()
  loadData()
}

onMounted(() => {
  loadData()
})

onMounted(() => {
  window.addEventListener('resize', () => {
    if (dailyExpenseChart) dailyExpenseChart.resize()
    if (categoryChart) categoryChart.resize()
  })
})
</script>

<style scoped>
.month-report {
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