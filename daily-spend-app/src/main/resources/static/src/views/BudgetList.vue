<template>
  <div class="budget-list">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>预算管理</span>
          <el-button type="primary" @click="handleAdd">新增预算</el-button>
        </div>
      </template>
      
      <el-table :data="tableData" style="width: 100%">
        <el-table-column prop="type.name" label="类别" />
        <el-table-column prop="budgetAmount" label="预算金额">
          <template #default="{ row }">
            ¥{{ row.budgetAmount }}
          </template>
        </el-table-column>
        <el-table-column prop="actualAmount" label="实际支出">
          <template #default="{ row }">
            ¥{{ row.actualAmount }}
          </template>
        </el-table-column>
        <el-table-column prop="difference" label="差额">
          <template #default="{ row }">
            <span :class="{ 'text-danger': row.difference < 0, 'text-success': row.difference >= 0 }">
              ¥{{ row.difference }}
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="percentage" label="完成率">
          <template #default="{ row }">
            <el-progress 
              :percentage="Math.min(row.percentage, 100)" 
              :color="row.percentage > 100 ? '#ff4949' : '#67c23a'"
            />
          </template>
        </el-table-column>
        <el-table-column prop="startDate" label="开始日期" width="120" />
        <el-table-column prop="endDate" label="结束日期" width="120" />
        <el-table-column label="操作" width="150">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
    
    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogType === 'add' ? '新增预算' : '编辑预算'"
      width="500px"
    >
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="类别" prop="typeId">
          <el-select v-model="form.typeId" placeholder="选择类别">
            <el-option
              v-for="type in types"
              :key="type.typeId"
              :label="type.name"
              :value="type.typeId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="预算金额" prop="budgetAmount">
          <el-input-number v-model="form.budgetAmount" :min="0" :precision="2" :step="100" />
        </el-form-item>
        <el-form-item label="开始日期" prop="startDate">
          <el-date-picker v-model="form.startDate" type="date" placeholder="选择开始日期" />
        </el-form-item>
        <el-form-item label="结束日期" prop="endDate">
          <el-date-picker v-model="form.endDate" type="date" placeholder="选择结束日期" />
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
import { budgetApi, typeApi } from '../api'

const tableData = ref([])
const types = ref([])
const dialogVisible = ref(false)
const dialogType = ref('add')
const formRef = ref()

const form = reactive({
  budgetId: null,
  typeId: '',
  budgetAmount: 0,
  startDate: new Date(),
  endDate: new Date()
})

const rules = {
  typeId: [{ required: true, message: '请选择类别', trigger: 'change' }],
  budgetAmount: [{ required: true, message: '请输入预算金额', trigger: 'blur' }],
  startDate: [{ required: true, message: '请选择开始日期', trigger: 'change' }],
  endDate: [{ required: true, message: '请选择结束日期', trigger: 'change' }]
}

const loadData = async () => {
  try {
    const response = await budgetApi.getAll()
    tableData.value = response.data
  } catch (error) {
    ElMessage.error('加载数据失败')
  }
}

const loadTypes = async () => {
  try {
    const response = await typeApi.getAll()
    types.value = response.data
  } catch (error) {
    ElMessage.error('加载类别失败')
  }
}

const handleAdd = () => {
  dialogType.value = 'add'
  Object.assign(form, {
    budgetId: null,
    typeId: '',
    budgetAmount: 0,
    startDate: new Date(),
    endDate: new Date()
  })
  dialogVisible.value = true
}

const handleEdit = (row) => {
  dialogType.value = 'edit'
  Object.assign(form, {
    budgetId: row.budgetId,
    typeId: row.type.typeId,
    budgetAmount: row.budgetAmount,
    startDate: new Date(row.startDate),
    endDate: new Date(row.endDate)
  })
  dialogVisible.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定要删除这个预算吗？', '提示', {
      type: 'warning'
    })
    await budgetApi.delete(row.budgetId)
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
      await budgetApi.create(form)
      ElMessage.success('添加成功')
    } else {
      await budgetApi.update(form.budgetId, form)
      ElMessage.success('更新成功')
    }
    dialogVisible.value = false
    loadData()
  } catch (error) {
    ElMessage.error('操作失败')
  }
}

onMounted(() => {
  loadData()
  loadTypes()
})
</script>

<style scoped>
.budget-list {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.text-danger {
  color: #ff4949;
}

.text-success {
  color: #67c23a;
}
</style>