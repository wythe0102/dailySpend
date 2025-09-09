<template>
  <div class="month-report">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>月报表</span>
        </div>
      </template>
      
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="选择月份">
          <el-date-picker
            v-model="searchForm.month"
            type="month"
            placeholder="选择月份"
            format="YYYY年MM月"
            value-format="YYYY-MM"
            @change="handleSearch"
          />
        </el-form-item>
      </el-form>
      
      <el-card>
        <template #header>
          <span>当月每日消费汇总</span>
        </template>
        <div id="daily-expense-chart" style="height: 400px;"></div>
      </el-card>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { dailySpendApi } from '../api'
import * as echarts from 'echarts'

const searchForm = reactive({
  userId: 1, // 默认用户ID
  month: new Date().toISOString().slice(0, 7) // 格式化为 YYYY-MM
})

const router = useRouter()
let dailyExpenseChart = null

const loadData = async () => {
  try {
    if (!searchForm.month) return
    
    const [year, monthNum] = searchForm.month.split('-')
    const month = parseInt(monthNum) - 1 // JavaScript月份从0开始
    const startDate = new Date(year, month, 1)
    const endDate = new Date(year, month + 1, 0)
    
    const response = await dailySpendApi.getByUserIdAndDateRange(
      searchForm.userId,
      startDate.toISOString().split('T')[0],
      endDate.toISOString().split('T')[0]
    )
    
    const data = response.data
    processDailyData(data, startDate, endDate)
  } catch (error) {
    ElMessage.error('加载数据失败')
  }
}

const processDailyData = (data, startDate, endDate) => {
  const daysInMonth = endDate.getDate()
  const dailyData = Array(daysInMonth).fill(0)
  
  // 计算每日消费汇总
  data.forEach(item => {
    const date = new Date(item.date)
    const day = date.getDate() - 1
    dailyData[day] += item.amount
  })
  
  // 更新图表
  updateDailyChart(dailyData, startDate)
}

const updateDailyChart = (dailyData, startDate) => {
  if (dailyExpenseChart) {
    dailyExpenseChart.dispose()
  }
  dailyExpenseChart = echarts.init(document.getElementById('daily-expense-chart'))
  
  const year = startDate.getFullYear()
  const month = startDate.getMonth() + 1
  const monthStr = `${year}年${month}月`
  
  const xAxisData = Array.from({ length: dailyData.length }, (_, i) => `${i + 1}日`)
  
  dailyExpenseChart.setOption({
    title: {
      text: `${monthStr}每日消费汇总`,
      left: 'center'
    },
    tooltip: {
      trigger: 'axis',
      formatter: function(params) {
        const day = params[0].axisValue
        const amount = params[0].value
        return `${monthStr}${day}<br/>消费: ¥${amount.toFixed(2)}`
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      boundaryGap: false,
      data: xAxisData
    },
    yAxis: {
      type: 'value',
      name: '消费金额',
      axisLabel: {
        formatter: '¥{value}'
      }
    },
    series: [
      {
        name: '每日消费',
        type: 'line',
        data: dailyData,
        smooth: true,
        symbol: 'circle',
        symbolSize: 6,
        lineStyle: {
          width: 3,
          color: '#409EFF'
        },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(64, 158, 255, 0.3)' },
            { offset: 1, color: 'rgba(64, 158, 255, 0.1)' }
          ])
        },
        itemStyle: {
          color: '#409EFF'
        }
      }
    ],
    // 添加点击事件提示
    graphic: [
      {
        type: 'text',
        left: 'center',
        bottom: 10,
        style: {
          text: '点击数据点查看当天详细记录',
          textAlign: 'center',
          fill: '#999',
          fontSize: 12
        }
      }
    ]
  })
  
  // 添加点击事件监听
  dailyExpenseChart.on('click', function(params) {
    if (params.componentType === 'series') {
      const day = params.dataIndex + 1
      const [year, month] = searchForm.month.split('-')
      const dateStr = `${year}-${month.padStart(2, '0')}-${day.toString().padStart(2, '0')}`
      
      // 跳转到日常记账页面，并传递日期参数
      router.push({
        path: '/daily-spends',
        query: { date: dateStr }
      })
    }
  })
}

const handleSearch = () => {
  loadData()
}

onMounted(() => {
  loadData()
  
  window.addEventListener('resize', () => {
    if (dailyExpenseChart) dailyExpenseChart.resize()
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
</style>