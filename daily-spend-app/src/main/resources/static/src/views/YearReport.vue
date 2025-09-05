<template>
  <div class="year-report">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>年度报表</span>
        </div>
      </template>
      
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="选择年份">
          <el-date-picker
            v-model="searchForm.year"
            type="year"
            placeholder="选择年份"
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
              <div class="card-title">年度总支出</div>
              <div class="card-value">¥{{ summary.totalExpense }}</div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="summary-card">
            <div class="card-content">
              <div class="card-title">年度总收入</div>
              <div class="card-value">¥{{ summary.totalIncome }}</div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="summary-card">
            <div class="card-content">
              <div class="card-title">年度净收入</div>
              <div class="card-value" :class="{ 'text-success': summary.netIncome >= 0, 'text-danger': summary.netIncome < 0 }">
                ¥{{ summary.netIncome }}
              </div>
            </div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card class="summary-card">
            <div class="card-content">
              <div class="card-title">月均支出</div>
              <div class="card-value">¥{{ summary.monthlyExpense }}</div>
            </div>
          </el-card>
        </el-col>
      </el-row>
      
      <el-row :gutter="20" class="charts">
        <el-col :span="12">
          <el-card>
            <template #header>
              <span>月度收支趋势</span>
            </template>
            <div id="monthly-trend-chart" style="height: 300px;"></div>
          </el-card>
        </el-col>
        <el-col :span="12">
          <el-card>
            <template #header>
              <span>年度类别统计</span>
            </template>
            <div id="yearly-category-chart" style="height: 300px;"></div>
          </el-card>
        </el-col>
      </el-row>
      
      <el-table :data="tableData" style="width: 100%">
        <el-table-column prop="month" label="月份" />
        <el-table-column prop="expense" label="支出">
          <template #default="{ row }">
            ¥{{ row.expense }}
          </template>
        </el-table-column>
        <el-table-column prop="income" label="收入">
          <template #default="{ row }">
            ¥{{ row.income }}
          </template>
        </el-table-column>
        <el-table-column prop="net" label="净收入">
          <template #default="{ row }">
            <span :class="{ 'text-success': row.net >= 0, 'text-danger': row.net < 0 }">
              ¥{{ row.net }}
            </span>
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
  netIncome: 0,
  monthlyExpense: 0
})

const searchForm = reactive({
  userId: 1, // 默认用户ID
  year: new Date()
})

let monthlyTrendChart = null
let yearlyCategoryChart = null

const loadData = async () => {
  try {
    const year = searchForm.year.getFullYear()
    const startDate = new Date(year, 0, 1)
    const endDate = new Date(year, 11, 31)
    
    const response = await dailySpendApi.getByUserIdAndDateRange(
      searchForm.userId,
      startDate.toISOString().split('T')[0],
      endDate.toISOString().split('T')[0]
    )
    
    const data = response.data
    processData(data, year)
  } catch (error) {
    ElMessage.error('加载数据失败')
  }
}

const processData = (data, year) => {
  const monthlyData = Array(12).fill(0).map(() => ({ expense: 0, income: 0 }))
  
  // 计算汇总数据
  const expenseData = data.filter(item => item.type.type === 'EXPENSE')
  const incomeData = data.filter(item => item.type.type === 'INCOME')
  
  summary.totalExpense = expenseData.reduce((sum, item) => sum + item.amount, 0)
  summary.totalIncome = incomeData.reduce((sum, item) => sum + item.amount, 0)
  summary.netIncome = summary.totalIncome - summary.totalExpense
  summary.monthlyExpense = (summary.totalExpense / 12).toFixed(2)
  
  // 按月份分组
  expenseData.forEach(item => {
    const date = new Date(item.date)
    const month = date.getMonth()
    monthlyData[month].expense += item.amount
  })
  
  incomeData.forEach(item => {
    const date = new Date(item.date)
    const month = date.getMonth()
    monthlyData[month].income += item.amount
  })
  
  // 更新表格数据
  tableData.value = monthlyData.map((data, index) => ({
    month: `${year}年${index + 1}月`,
    expense: data.expense.toFixed(2),
    income: data.income.toFixed(2),
    net: (data.income - data.expense).toFixed(2)
  }))
  
  // 更新图表
  updateCharts(monthlyData)
}

const updateCharts = (monthlyData) => {
  // 月度收支趋势图
  if (monthlyTrendChart) {
    monthlyTrendChart.dispose()
  }
  monthlyTrendChart = echarts.init(document.getElementById('monthly-trend-chart'))
  monthlyTrendChart.setOption({
    tooltip: {
      trigger: 'axis'
    },
    legend: {
      data: ['支出', '收入']
    },
    xAxis: {
      type: 'category',
      data: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月']
    },
    yAxis: {
      type: 'value',
      name: '金额'
    },
    series: [
      {
        name: '支出',
        type: 'line',
        data: monthlyData.map(item => item.expense),
        smooth: true,
        itemStyle: { color: '#ff4949' }
      },
      {
        name: '收入',
        type: 'line',
        data: monthlyData.map(item => item.income),
        smooth: true,
        itemStyle: { color: '#67c23a' }
      }
    ]
  })
  
  // 年度类别统计图
  if (yearlyCategoryChart) {
    yearlyCategoryChart.dispose()
  }
  yearlyCategoryChart = echarts.init(document.getElementById('yearly-category-chart'))
  
  const categoryData = {}
  const data = tableData.value
  
  // 重新获取所有数据来计算类别统计
  const loadCategoryData = async () => {
    const year = searchForm.year.getFullYear()
    const startDate = new Date(year, 0, 1)
    const endDate = new Date(year, 11, 31)
    
    const response = await dailySpendApi.getByUserIdAndDateRange(
      searchForm.userId,
      startDate.toISOString().split('T')[0],
      endDate.toISOString().split('T')[0]
    )
    
    const expenseData = response.data.filter(item => item.type.type === 'EXPENSE')
    const categoryGroups = {}
    
    expenseData.forEach(item => {
      if (!categoryGroups[item.type.name]) {
        categoryGroups[item.type.name] = 0
      }
      categoryGroups[item.type.name] += item.amount
    })
    
    yearlyCategoryChart.setOption({
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
          data: Object.entries(categoryGroups).map(([name, value]) => ({
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
  
  loadCategoryData()
}

const handleSearch = () => {
  loadData()
}

onMounted(() => {
  loadData()
})

onMounted(() => {
  window.addEventListener('resize', () => {
    if (monthlyTrendChart) monthlyTrendChart.resize()
    if (yearlyCategoryChart) yearlyCategoryChart.resize()
  })
})
</script>

<style scoped>
.year-report {
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