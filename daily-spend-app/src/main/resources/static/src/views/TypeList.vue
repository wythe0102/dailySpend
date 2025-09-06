<template>
  <div class="type-list">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>类别管理</span>
          <el-button type="primary" @click="handleAdd">新增类别</el-button>
        </div>
      </template>
      
      <el-table :data="tableData" style="width: 100%" row-key="typeId" lazy>
        <el-table-column prop="name" label="类别名称" />
        <el-table-column prop="code" label="编码" />
        <el-table-column prop="sequence" label="顺序" />
        <el-table-column label="父类别">
          <template #default="{ row }">
            {{ getParentName(row.parentId) }}
          </template>
        </el-table-column>

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
      :title="dialogType === 'add' ? '新增类别' : '编辑类别'"
      width="500px"
    >
      <el-form :model="form" :rules="rules" ref="formRef" label-width="80px">
        <el-form-item label="类别名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入类别名称" />
        </el-form-item>
        <el-form-item label="编码" prop="code">
          <el-input v-model="form.code" placeholder="请输入类别编码" />
        </el-form-item>
        <el-form-item label="顺序" prop="sequence">
          <el-input-number v-model="form.sequence" :min="0" placeholder="请输入顺序" />
        </el-form-item>
        <el-form-item label="父类别" prop="parentId">
          <el-select v-model="form.parentId" placeholder="选择父类别" clearable>
            <el-option
              v-for="type in allTypes"
              :key="type.typeId"
              :label="type.name"
              :value="type.typeId"
            />
          </el-select>
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
import { typeApi } from '../api'

const tableData = ref([])
const allTypes = ref([])
const dialogVisible = ref(false)
const dialogType = ref('add')
const formRef = ref()

const form = reactive({
  typeId: null,
  name: '',
  code: '',
  sequence: 0,
  parentId: null,
  type: 'EXPENSE'
})

const rules = {
  name: [{ required: true, message: '请输入类别名称', trigger: 'blur' }],
  code: [{ required: true, message: '请输入类别编码', trigger: 'blur' }],
  sequence: [{ required: true, message: '请输入顺序', trigger: 'blur' }]
}

const loadData = async () => {
  try {
    const response = await typeApi.getAll()
    allTypes.value = response.data
    tableData.value = response.data.filter(type => type.name !== '类型') // 过滤掉"类型"类别
  } catch (error) {
    ElMessage.error('加载数据失败')
  }
}

const handleAdd = () => {
  dialogType.value = 'add'
  Object.assign(form, {
    typeId: null,
    name: '',
    code: '',
    sequence: 0,
    parentId: null,
    type: 'EXPENSE'
  })
  dialogVisible.value = true
}

const handleEdit = (row) => {
  dialogType.value = 'edit'
  Object.assign(form, {
    typeId: row.typeId,
    name: row.name,
    code: row.code,
    sequence: row.sequence,
    parentId: row.parentId || null,
    type: row.type
  })
  dialogVisible.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定要删除这个类别吗？', '提示', {
      type: 'warning'
    })
    await typeApi.delete(row.typeId)
    ElMessage.success('删除成功')
    loadData()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

const getParentName = (parentId) => {
  if (!parentId) return ''
  const parent = allTypes.value.find(type => type.typeId === parentId)
  return parent ? parent.name : ''
}

const handleSubmit = async () => {
  try {
    await formRef.value.validate()
    const submitData = {
      name: form.name,
      code: form.code,
      sequence: form.sequence,
      parentId: form.parentId,
      type: form.type
    }
    
    if (dialogType.value === 'add') {
      await typeApi.create(submitData)
      ElMessage.success('添加成功')
    } else {
      submitData.typeId = form.typeId
      await typeApi.update(form.typeId, submitData)
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
})
</script>

<style scoped>
.type-list {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>