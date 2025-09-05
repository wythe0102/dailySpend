<template>
  <div class="daily-weight-list">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>体重记录</span>
          <el-button type="primary" @click="handleAdd">新增记录</el-button>
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
        <el-table-column prop="date" label="日期" width="120" />
        <el-table-column prop="weight" label="体重(kg)" width="100" />
        <el-table-column prop="note" label="备注" />
        <el-table-column label="操作" width="150">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <el-pagination
        v-model:current-page="currentPage"
        :page-size="pageSize"
        :total="total"
        layout="total, prev, pager, next"
        @current-change="handlePageChange"
      />
    </el-card>
    
    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogType === 'add' ? '新增记录' : '编辑记录'"
      width="500px"
    >
      <el-form :model="form" :rules="rules" ref="formRef" label-width="80px">
        <el-form-item label="日期" prop="date">
          <el-date-picker v-model="form.date" type="date" placeholder="选择日期" />
        </el-form-item>
        <el-form-item label="体重" prop="weight">
          <el-input-number v-model="form.weight" :min="0" :max="200" :precision="2" :step="0.1" />
        </el-form-item>
        <el-form-item label="备注" prop="note">
          <el-input v-model="form.note" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { dailyWeightApi } from '../api'

const tableData = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const dialogVisible = ref(false)
const dialogType = ref('add')
const formRef = ref()

const searchForm = reactive({
  // 不再限制用户ID，获取所有用户数据
})

const dateRange = ref([])

const form = reactive({
  weightId: null,
  date: new Date(),
  weight: 0,
  note: '',
  userId: 1 // 新增记录时默认用户ID
})

const rules = {
  date: [{ required: true, message: '请选择日期', trigger: 'change' }],
  weight: [{ required: true, message: '请输入体重', trigger: 'blur' }]
}

const loadData = async () => {
  try {
    const response = await dailyWeightApi.getAll()
    tableData.value = response.data
    total.value = response.data.length
  } catch (error) {
    ElMessage.error('加载数据失败')
  }
}

const handleSearch = () => {
  loadData()
}

const handleReset = () => {
  dateRange.value = []
  loadData()
}

const handleAdd = () => {
  dialogType.value = 'add'
  Object.assign(form, {
    weightId: null,
    date: new Date(),
    weight: 0,
    note: '',
    userId: 1
  })
  dialogVisible.value = true
}

const handleEdit = (row) => {
  dialogType.value = 'edit'
  Object.assign(form, {
    ...row,
    date: new Date(row.date)
  })
  dialogVisible.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定要删除这条记录吗？', '提示', {
      type: 'warning'
    })
    await dailyWeightApi.delete(row.weightId)
    ElMessage.success('删除成功')
    loadData()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

const handleSubmit = async () => {
  try {
    await formRef.value.validate()
    if (dialogType.value === 'add') {
      await dailyWeightApi.create(form)
      ElMessage.success('添加成功')
    } else {
      await dailyWeightApi.update(form.weightId, form)
      ElMessage.success('更新成功')
    }
    dialogVisible.value = false
    loadData()
  } catch (error) {
    ElMessage.error('操作失败')
  }
}

const handlePageChange = (page) => {
  currentPage.value = page
  loadData()
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.daily-weight-list {
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