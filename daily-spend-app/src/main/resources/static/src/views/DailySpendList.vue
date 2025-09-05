<template>
  <div class="daily-spend-list">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>日常记账</span>
          <el-button type="primary" @click="handleAdd">新增记账</el-button>
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
        <el-form-item label="类别" prop="typeIds">
          <el-cascader
          ref="cascaderRef"
          v-model="searchForm.typeIds"
          :options="types"
          :props="cascaderProps"
          placeholder="选择类别"
          clearable
          multiple
          collapse-tags
          :show-all-levels="false"
          @visible-change="handleCascaderVisibleChange"
        />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
      
      <el-table :data="tableData" style="width: 100%">
        <el-table-column prop="date" label="日期" width="120" />
        <el-table-column prop="type.name" label="类别" width="120" />
        <el-table-column prop="amount" label="金额" width="100">
          <template #default="{ row }">
            <span :style="{ color: row.amount > 100 ? '#f56c6c' : '' }">
              {{ row.amount }}
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="demo" label="备注" />
        <el-table-column prop="user.name" label="消费人员" width="100" />
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
      :title="dialogType === 'add' ? '新增记账' : '编辑记账'"
      width="500px"
    >
      <el-form :model="form" :rules="rules" ref="formRef" label-width="80px">
        <el-form-item label="日期" prop="date">
          <el-date-picker v-model="form.date" type="date" placeholder="选择日期" />
        </el-form-item>
        <el-form-item label="类别" prop="typeId">
          <el-cascader
            v-model="form.typeId"
            :options="types"
            :props="cascaderProps"
            placeholder="选择类别"
            clearable
          />
        </el-form-item>
        <el-form-item label="金额" prop="amount">
          <el-input-number v-model="form.amount" :min="0" :precision="2" :step="0.01" />
        </el-form-item>
        <el-form-item label="备注" prop="demo">
          <el-input v-model="form.demo" type="textarea" :rows="3" />
        </el-form-item>
        <el-form-item label="用户" prop="userId">
          <el-select v-model="form.userId" placeholder="选择用户">
            <el-option label="用户1" :value="1" />
            <el-option label="用户2" :value="2" />
            <el-option label="用户3" :value="3" />
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
import { dailySpendApi, typeApi } from '../api'

const tableData = ref([])
const types = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const dialogVisible = ref(false)
const dialogType = ref('add')
const formRef = ref()

const cascaderProps = {
  value: 'typeId',
  label: 'name',
  children: 'children',
  multiple: true, // 启用多选
  checkStrictly: true, // 允许选择任意级别的节点
  emitPath: false, // 只返回选中的节点值，而不是路径数组
  expandTrigger: 'hover' // 鼠标悬停展开子节点，无需点击
}

const cascaderRef = ref()

const searchForm = reactive({
  typeIds: [],
  userId: 1 // 默认用户ID
})

const dateRange = ref([])

const form = reactive({
  spendDetailId: null,
  date: new Date(),
  typeId: '',
  amount: 0,
  demo: '',
  userId: 1
})

const rules = {
  date: [{ required: true, message: '请选择日期', trigger: 'change' }],
  typeId: [{ required: true, message: '请选择类别', trigger: 'change' }],
  amount: [{ required: true, message: '请输入金额', trigger: 'blur' }],
  userId: [{ required: true, message: '请选择用户', trigger: 'change' }]
}

const loadData = async () => {
  try {
    const params = {
      userId: searchForm.userId,
      page: currentPage.value - 1,
      size: pageSize.value
    }
    if (searchForm.typeIds && searchForm.typeIds.length > 0) {
      params.typeIds = searchForm.typeIds.join(',')
    }
    const response = await dailySpendApi.getPage(params)
    tableData.value = response.data.content
    total.value = response.data.totalElements
  } catch (error) {
    ElMessage.error('加载数据失败')
  }
}

const loadTypes = async () => {
  try {
    const response = await typeApi.getAll()
    const allTypes = response.data
    types.value = buildTree(allTypes)
  } catch (error) {
    ElMessage.error('加载类别失败')
  }
}

const buildTree = (types) => {
  const typeMap = {}
  const tree = []
  
  // 创建映射，包含所有类别
  types.forEach(type => {
    typeMap[type.typeId] = { 
      typeId: type.typeId,
      name: type.name,
      parentId: type.parentId,
      sequence: type.sequence,
      children: []
    }
  })
  
  // 构建树结构
  types.forEach(type => {
    if (type.parentId && typeMap[type.parentId] && type.parentId !== 1) {
      // 添加到父节点的children中，排除根节点(parentId=1)
      typeMap[type.parentId].children.push(typeMap[type.typeId])
    } else if (!type.parentId || type.parentId === 1) {
      // 根节点(parentId=1或null)作为顶层节点
      if (type.typeId !== 1) { // 排除根类别本身
        tree.push(typeMap[type.typeId])
      }
    }
  })
  
  // 按sequence排序
  tree.forEach(node => {
    if (node.children && node.children.length > 0) {
      node.children.sort((a, b) => (a.sequence || 0) - (b.sequence || 0))
    }
  })
  
  return tree.sort((a, b) => (a.sequence || 0) - (b.sequence || 0))
}

const handleSearch = () => {
  loadData()
}

const handleReset = () => {
  searchForm.typeIds = []
  dateRange.value = []
  currentPage.value = 1
  loadData()
}

const handleCascaderVisibleChange = (visible) => {
  if (visible && cascaderRef.value) {
    // 当下拉框显示时，展开所有节点
    nextTick(() => {
      cascaderRef.value.togglePopperVisible()
    })
  }
}

const handleAdd = () => {
  dialogType.value = 'add'
  Object.assign(form, {
    spendDetailId: null,
    date: new Date(),
    typeId: '',
    amount: 0,
    demo: '',
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
    await dailySpendApi.delete(row.spendDetailId)
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
      await dailySpendApi.create(form)
      ElMessage.success('添加成功')
    } else {
      await dailySpendApi.update(form.spendDetailId, form)
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
  loadTypes()
})
</script>

<style scoped>
.daily-spend-list {
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