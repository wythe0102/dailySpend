<template>
  <div class="type-list">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>类别管理</span>
          <el-button type="primary" @click="handleAdd">新增类别</el-button>
        </div>
      </template>
      
      <el-table 
        :data="treeData" 
        style="width: 100%" 
        row-key="typeId" 
        default-expand-all
        :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
      >
        <el-table-column prop="name" label="类别名称" width="200">
          <template #default="{ row }">
            <span :style="{ paddingLeft: (row.level * 20) + 'px' }">
              <i v-if="row.children && row.children.length > 0" class="el-icon-folder"></i>
              <i v-else class="el-icon-document"></i>
              {{ row.name }}
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="code" label="编码" width="120" />
        <el-table-column prop="sequence" label="顺序" width="80" />

        <el-table-column label="创建时间" width="120">
          <template #default="{ row }">
            {{ row.addDate ? formatDate(row.addDate) : '-' }}
          </template>
        </el-table-column>

        <el-table-column label="操作" width="150" fixed="right">
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
              v-for="type in getAvailableParents()"
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

const treeData = ref([])
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
    const filteredData = response.data.filter(type => type.name !== '类型') // 过滤掉"类型"类别
    treeData.value = buildTreeData(filteredData)
  } catch (error) {
    ElMessage.error('加载数据失败')
  }
}

const buildTreeData = (data) => {
  const map = {}
  const roots = []
  
  // 初始化所有节点
  data.forEach(item => {
    map[item.typeId] = { ...item, children: [], level: 0 }
  })
  
  // 构建树形结构
  data.forEach(item => {
    if (item.parentId && map[item.parentId] && item.parentId !== item.typeId) {
      // 设置层级
      map[item.typeId].level = map[item.parentId].level + 1
      map[item.parentId].children.push(map[item.typeId])
    } else {
      // 根节点
      map[item.typeId].level = 0
      roots.push(map[item.typeId])
    }
  })
  
  // 按sequence排序
  const sortBySequence = (nodes) => {
    nodes.sort((a, b) => a.sequence - b.sequence)
    nodes.forEach(node => {
      if (node.children && node.children.length > 0) {
        sortBySequence(node.children)
      }
    })
  }
  
  sortBySequence(roots)
  return roots
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN')
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

const getAvailableParents = () => {
  // 在编辑模式下，过滤掉当前节点及其子节点
  if (dialogType.value === 'edit') {
    const currentId = form.typeId
    const excludeIds = new Set()
    
    // 递归获取所有子节点ID
    const getAllChildrenIds = (parentId) => {
      excludeIds.add(parentId)
      const children = allTypes.value.filter(type => type.parentId === parentId)
      children.forEach(child => {
        getAllChildrenIds(child.typeId)
      })
    }
    
    if (currentId) {
      getAllChildrenIds(currentId)
    }
    
    return allTypes.value.filter(type => !excludeIds.has(type.typeId))
  }
  
  // 新增模式下返回所有类别
  return allTypes.value
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
      // 不设置addDate，让后端自动填充
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

:deep(.el-table__row) {
  transition: all 0.3s ease;
}

:deep(.el-table__row:hover) {
  background-color: #f5f7fa;
}

.tree-node {
  display: flex;
  align-items: center;
}

.tree-icon {
  margin-right: 8px;
  color: #909399;
}
</style>