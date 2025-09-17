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
      
      <el-row class="charts">
        <el-col :span="24">
          <el-card>
            <template #header>
              <span>{{ searchForm.year.getFullYear() }}年月度消费汇总走势</span>
            </template>
            <div id="monthly-expense-chart" style="height: 400px;"></div>
          </el-card>
        </el-col>
      </el-row>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { dailySpendApi } from '../api'
import * as echarts from 'echarts'

const searchForm = reactive({
  userId: 1, // 默认用户ID
  year: new Date()
})

const router = useRouter()
let monthlyExpenseChart = null

const loadData = async () => {
  try {
    const year = searchForm.year.getFullYear()
    const startDate = new Date(year, 0, 1)
    const endDate = new Date(year, 11, 31)
    
    // 确保日期格式为YYYY-MM-DD，避免时区问题
    const formatDate = (date) => {
      const d = new Date(date)
      const year = d.getFullYear()
      const month = String(d.getMonth() + 1).padStart(2, '0')
      const day = String(d.getDate()).padStart(2, '0')
      return `${year}-${month}-${day}`
    }
    
    const formattedStartDate = formatDate(startDate)
    const formattedEndDate = formatDate(endDate)
    
    console.log('加载数据参数:', {
      userId: searchForm.userId,
      startDate: formattedStartDate,
      endDate: formattedEndDate
    })
    
    // 调用正确的API方法
    const response = await dailySpendApi.getByUserIdAndDateRange(
      searchForm.userId,
      formattedStartDate,
      formattedEndDate
    )
    
    console.log('API返回数据数量:', response.data.length)
    if (response.data.length > 0) {
      console.log('API返回数据示例:', response.data.slice(0, 3))
    }
    
    const data = response.data
    processData(data)
  } catch (error) {
    console.error('加载数据失败:', error)
    ElMessage.error('加载数据失败: ' + (error.response?.data?.message || error.message))
  }
}

const processData = (data) => {
  // 初始化12个月的数据
  const monthlyExpenseData = Array(12).fill(0)
  
  console.log('开始处理数据，共', data.length, '条记录')
  
  // 按月份统计消费金额和计算年度总计
  let yearlyTotal = 0
  data.forEach(item => {
    try {
      // 确保item是有效的消费记录对象
      if (item && item.amount !== undefined && item.date) {
        // 计算月份（0-11）
        const date = new Date(item.date)
        const month = date.getMonth()
        
        // 添加到对应月份的总金额和年度总计中
        const amount = Number(item.amount)
        monthlyExpenseData[month] += amount
        yearlyTotal += amount
      }
    } catch (error) {
      console.error('处理单条记录时出错:', error, '记录:', item)
    }
  })
  
  // 显示统计结果
  console.log('月度消费统计结果:', monthlyExpenseData)
  console.log('年度消费总计:', yearlyTotal)
  
  // 更新图表
  updateExpenseChart(monthlyExpenseData, yearlyTotal)
}

const updateExpenseChart = (monthlyExpenseData, yearlyTotal) => {
  if (monthlyExpenseChart) {
    monthlyExpenseChart.dispose()
  }
  
  monthlyExpenseChart = echarts.init(document.getElementById('monthly-expense-chart'))
  
  const year = searchForm.year.getFullYear()
  
  monthlyExpenseChart.setOption({
    title: {
      text: `${year}年月度消费汇总走势（总计：¥${yearlyTotal.toFixed(2)}）`,
      left: 'center'
    },
    tooltip: {
      trigger: 'axis',
      formatter: '{b}: ¥{c}'
    },
    xAxis: {
      type: 'category',
      data: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
      name: '月份'
    },
    yAxis: {
      type: 'value',
      name: '支出金额（元）',
      axisLabel: {
        formatter: '¥{value}'
      }
    },
    series: [
      {
        name: '月度支出',
        type: 'line',
        data: monthlyExpenseData,
        smooth: true,
        symbol: 'circle',
        symbolSize: 8,
        itemStyle: {
          color: '#ff4949'
        },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            {
              offset: 0,
              color: 'rgba(255, 73, 73, 0.3)'
            },
            {
              offset: 1,
              color: 'rgba(255, 73, 73, 0.05)'
            }
          ])
        },
        lineStyle: {
          width: 3
        },
        emphasis: {
          focus: 'series',
          itemStyle: {
            shadowBlur: 10,
            shadowColor: 'rgba(255, 73, 73, 0.5)'
          }
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
          text: '点击数据点查看该月详细报表',
          textAlign: 'center',
          fill: '#999',
          fontSize: 12
        }
      }
    ],
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    }
  })
  
  // 添加点击事件监听
  monthlyExpenseChart.on('click', function(params) {
    if (params.componentType === 'series') {
      const month = params.dataIndex + 1 // 月份从0开始，需要+1
      const year = searchForm.year.getFullYear()
      const monthStr = String(month).padStart(2, '0')
      const dateStr = `${year}-${monthStr}`
      
      // 跳转到月报表页面，并传递月份参数
      router.push({
        path: '/reports/month',
        query: { month: dateStr }
      })
    }
  })
}

const handleSearch = () => {
  loadData()
}

onMounted(() => {
  loadData()
  
  // 添加窗口大小调整事件监听
  window.addEventListener('resize', () => {
    if (monthlyExpenseChart) {
      monthlyExpenseChart.resize()
    }
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

.charts {
  margin-top: 20px;
}
</style>