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
      

      
      <el-table :data="tableData" style="width: 100%">
        <el-table-column prop="date" label="日期" width="120">
          <template #default="{ row }">
            <el-button 
              type="text" 
              @click="handleDateClick(row.date)"
              style="color: #409eff; text-decoration: underline; cursor: pointer;"
            >
              {{ formatDate(row.date) }}
            </el-button>
          </template>
        </el-table-column>
        <el-table-column prop="totalAmount" label="总金额" width="150">
          <template #default="{ row }">
            ¥{{ row.totalAmount.toFixed(2) }}
          </template>
        </el-table-column>
        <el-table-column prop="count" label="笔数" width="100" />
      </el-table>
      
      <el-pagination
        v-model:current-page="currentPage"
        :page-size="pageSize"
        :total="total"
        layout="total, prev, pager, next"
        @current-change="handlePageChange"
      />
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { dailySpendApi } from '../api'

const router = useRouter()

const tableData = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

const searchForm = reactive({
  // 不再限制用户ID，获取所有用户数据
})

const dateRange = ref([])

const loadData = async () => {
  try {
    const params = {
      // 不再使用分页参数，获取所有数据进行前端汇总
      size: 10000  // 设置一个大数字获取所有数据
    }
    
    // 处理日期范围
    if (dateRange.value && dateRange.value.length === 2) {
      const startDate = dateRange.value[0]
      const endDate = dateRange.value[1]
      
      if (startDate && endDate) {
        params.startDate = startDate.toISOString().split('T')[0]
        params.endDate = endDate.toISOString().split('T')[0]
      }
    }
    
    const response = await dailySpendApi.getPage(params)
    const data = response.data.content
    
    // 按日期分组汇总
    const dailyData = groupByDate(data)
    
    // 前端分页
    const startIndex = (currentPage.value - 1) * pageSize.value
    const endIndex = startIndex + pageSize.value
    tableData.value = dailyData.slice(startIndex, endIndex)
    total.value = dailyData.length
    
  } catch (error) {
    ElMessage.error('加载数据失败')
    console.error('加载数据失败:', error)
  }
}



const groupByDate = (data) => {
  const groups = {}
  data.forEach(item => {
    const date = item.date
    if (!groups[date]) {
      groups[date] = {
        date: date,
        totalAmount: 0,
        count: 0
      }
    }
    groups[date].totalAmount += item.amount
    groups[date].count += 1
  })
  
  // 按日期排序（倒序）
  return Object.values(groups).sort((a, b) => new Date(b.date) - new Date(a.date))
}

const formatDate = (dateStr) => {
  const date = new Date(dateStr)
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}



const handleSearch = () => {
  currentPage.value = 1
  loadData()
}

const handleReset = () => {
  dateRange.value = []
  currentPage.value = 1
  loadData()
}

const handlePageChange = (page) => {
  currentPage.value = page
  loadData()
}

const handleDateClick = (date) => {
  // 跳转到日常记账界面，并传递选中的日期
  router.push({
    name: 'DailySpends',
    query: {
      date: date,
      from: 'summary'
    }
  })
}

onMounted(() => {
  loadData()
})

// 监听日期范围变化
watch(dateRange, () => {
  loadData()
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
</style>