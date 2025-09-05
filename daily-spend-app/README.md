# 龙珊记账系统

一个基于Spring Boot + Vue 3的现代化个人记账管理系统，支持日常收支记录、体重管理、预算控制和数据报表分析。

## 项目特色

- 🎯 **全面的记账功能**：支持日常收支记录、分类管理
- 📊 **智能数据分析**：月度/年度报表，收支趋势图表
- ⚖️ **体重管理**：记录体重变化，关注健康生活
- 💰 **预算控制**：设置预算，实时监控支出
- 📱 **响应式设计**：支持PC和移动端访问
- 🔒 **数据安全**：后端API安全验证

## 技术栈

### 后端
- **Spring Boot 3.2.5** - 现代化Java后端框架
- **Spring Data JPA** - 数据访问层
- **Hibernate** - ORM框架
- **MySQL** - 关系型数据库
- **Maven** - 项目构建工具

### 前端
- **Vue 3** - 渐进式JavaScript框架
- **Element Plus** - 基于Vue 3的组件库
- **Vite** - 现代化构建工具
- **ECharts** - 图表可视化库
- **Pinia** - 状态管理
- **Vue Router** - 路由管理

## 项目结构

```
daily-spend-app/
├── src/main/java/com/dailyspend/          # 后端源码
│   ├── controller/                        # 控制器层
│   │   ├── MainController.java           # 主页控制器
│   │   ├── DailySpendController.java     # 记账API控制器
│   │   ├── TypeController.java         # 类别API控制器
│   │   ├── DailyWeightController.java    # 体重API控制器
│   │   └── BudgetController.java       # 预算API控制器
│   ├── service/                          # 业务逻辑层
│   │   ├── DailySpendService.java        # 记账服务
│   │   ├── TypeService.java             # 类别服务
│   │   ├── DailyWeightService.java      # 体重服务
│   │   └── BudgetService.java          # 预算服务
│   ├── repository/                      # 数据访问层
│   │   ├── DailySpendRepository.java   # 记账数据仓库
│   │   ├── TypeRepository.java         # 类别数据仓库
│   │   ├── DailyWeightRepository.java  # 体重数据仓库
│   │   └── BudgetRepository.java       # 预算数据仓库
│   ├── entity/                          # 实体类
│   │   ├── DailySpend.java              # 记账实体
│   │   ├── Type.java                   # 类别实体
│   │   ├── DailyWeight.java            # 体重实体
│   │   └── Budget.java                 # 预算实体
│   └── DailySpendApplication.java      # 启动类
├── src/main/resources/
│   ├── static/                          # 前端资源
│   │   ├── src/                        # 前端源码
│   │   │   ├── views/                  # 页面组件
│   │   │   │   ├── DailySpendList.vue  # 记账列表
│   │   │   │   ├── DailySpendSummary.vue # 记账汇总
│   │   │   │   ├── DailyWeightList.vue # 体重列表
│   │   │   │   ├── BudgetList.vue      # 预算列表
│   │   │   │   ├── TypeList.vue        # 类别管理
│   │   │   │   ├── MonthReport.vue       # 月度报表
│   │   │   │   └── YearReport.vue      # 年度报表
│   │   │   ├── router/                 # 路由配置
│   │   │   ├── api/                    # API服务
│   │   │   ├── App.vue                 # 根组件
│   │   │   └── main.js                # 入口文件
│   │   ├── package.json               # 前端依赖
│   │   └── vite.config.js            # Vite配置
│   └── application.properties        # 应用配置
└── pom.xml                            # Maven配置
```

## 功能模块

### 1. 日常记账管理
- ✅ 记录日常收支
- ✅ 按类别分类管理
- ✅ 支持日期筛选
- ✅ 金额统计汇总

### 2. 类别管理
- ✅ 多级类别支持
- ✅ 收支类型区分
- ✅ 类别层级管理

### 3. 体重记录
- ✅ 每日体重记录
- ✅ 体重变化趋势
- ✅ 备注信息记录

### 4. 预算管理
- ✅ 按类别设置预算
- ✅ 实时预算监控
- ✅ 预算完成率统计

### 5. 数据报表
- ✅ 月度收支报表
- ✅ 年度收支报表
- ✅ 收支趋势图表
- ✅ 类别占比分析

## 快速开始

### 环境要求
- Java 17+
- Node.js 16+
- MySQL 8.0+
- Maven 3.6+

### 1. 克隆项目
```bash
git clone [项目地址]
cd daily-spend-app
```

### 2. 数据库配置
```sql
-- 创建数据库
CREATE DATABASE daily_spend CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE daily_spend;
```

### 3. 后端配置
编辑 `src/main/resources/application.properties`：
```properties
# 数据库配置
spring.datasource.url=jdbc:mysql://localhost:3306/daily_spend?useSSL=false&serverTimezone=UTC
spring.datasource.username=root
spring.datasource.password=your_password

# JPA配置
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
```

### 4. 启动后端服务
```bash
# 安装依赖
mvn clean install

# 启动应用
mvn spring-boot:run
```
后端服务将在 `http://localhost:8080` 启动

### 5. 启动前端服务
```bash
# 进入前端目录
cd src/main/resources/static

# 安装依赖
npm install

# 启动开发服务器
npm run dev
```
前端服务将在 `http://localhost:3000` 启动

## API接口

### 日常记账API
- `GET /api/daily-spends` - 获取所有记账记录
- `GET /api/daily-spends/user/{userId}` - 获取用户记账记录
- `POST /api/daily-spends` - 创建记账记录
- `PUT /api/daily-spends/{id}` - 更新记账记录
- `DELETE /api/daily-spends/{id}` - 删除记账记录

### 类别管理API
- `GET /api/types` - 获取所有类别
- `GET /api/types/root` - 获取根类别
- `POST /api/types` - 创建类别
- `PUT /api/types/{id}` - 更新类别
- `DELETE /api/types/{id}` - 删除类别

### 体重记录API
- `GET /api/daily-weights` - 获取所有体重记录
- `GET /api/daily-weights/user/{userId}` - 获取用户体重记录
- `POST /api/daily-weights` - 创建体重记录
- `PUT /api/daily-weights/{id}` - 更新体重记录
- `DELETE /api/daily-weights/{id}` - 删除体重记录

### 预算管理API
- `GET /api/budgets` - 获取所有预算
- `GET /api/budgets/type/{typeId}` - 获取类别预算
- `POST /api/budgets` - 创建预算
- `PUT /api/budgets/{id}` - 更新预算
- `DELETE /api/budgets/{id}` - 删除预算

## 开发说明

### 数据库设计
- 采用JPA自动建表，无需手动创建表结构
- 支持数据库迁移和版本控制
- 实体类使用JPA注解配置

### 前端开发
- 使用Vue 3 Composition API
- Element Plus组件库提供丰富的UI组件
- Vite提供快速的开发体验
- 支持热重载和模块热替换

### 部署说明
- 前端构建：`npm run build`
- 后端打包：`mvn clean package`
- 生成的JAR文件包含前端静态资源

## 贡献指南

欢迎提交Issue和Pull Request来帮助改进项目！

## 许可证

本项目采用MIT许可证，详情请查看LICENSE文件。

## 联系方式

如有问题或建议，请通过以下方式联系：
- 邮箱：[your-email@example.com]
- GitHub Issues

---

**龙珊记账系统** - 让记账变得更简单！💰