# 图书共享借阅平台

C2C 图书共享借阅系统：用户可发布闲置图书、申请借阅、收藏与推荐；管理员负责分类、公告、轮播与用户管理。

## 技术栈

| 端 | 技术 |
|----|------|
| 后端 | Spring Boot 3.5、MyBatis-Plus、MySQL、JWT |
| 前端 | Vue 3、Vite、Element Plus、Vue Router、Axios、ECharts |
| 环境 | JDK 21、Node.js 20+、MySQL 8 |

## 目录结构

```
BookBorrow/
├── db/bookborrow.sql          # 数据库脚本（含种子数据）
├── files/                     # 上传文件与图书封面
├── src/                       # Spring Boot 后端
└── vue/                       # Vue 前端
```

## 快速开始

### 1. 数据库

1. 创建库并导入脚本：

```sql
CREATE DATABASE bookborrow DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

```bash
mysql -u root -p bookborrow < db/bookborrow.sql
```

2. 按本机修改 `src/main/resources/application.yml`：

- `ip`：MySQL 主机（默认 `127.0.0.1`）
- `spring.datasource.username` / `password`（默认 `root` / `123456`）

### 2. 启动后端

用 IDEA 打开项目，运行主类（Spring Boot），或：

```bash
mvn spring-boot:run
```

默认端口：**9090**。上传文件目录为项目根下 `files/`。

### 3. 启动前端

```bash
cd vue
npm install
npm run dev
```

默认地址：**http://127.0.0.1:5173**（端口占用时不会自动改端口，需先释放 5173）。

接口地址在 `vue/config/config.default.js`（默认 `http://127.0.0.1:9090`），需与后端一致。

## 默认账号

| 角色 | 用户名 | 密码 | 说明 |
|------|--------|------|------|
| 管理员 | `admin` | `admin` | 后台 `/back` |
| 普通用户 | `zhangsan` | `123456` | 前台 `/front` |
| 普通用户 | `lisi` | `123456` | 同上 |

公开注册仅支持普通用户，不能自助注册管理员。

## 主要功能

**用户端**

- 浏览 / 搜索图书、分类推荐、推荐榜与收藏榜
- 发布图书、申请借阅、确认归还、评价
- 收藏、推荐、站内消息、取书地址

**管理端**

- 图书 / 分类 / 借阅记录管理
- 公告、轮播图、用户封禁
- 数据概览图表

## 说明

- 图书状态：`可借阅` / `已借出` 一般随库存变化；`维护中` / `已下架` 可手工设置。
- 申请借阅时会锁定一册库存，避免超借。
- 密码为明文存储（便于课设演示）；正式环境请改为哈希并调整 JWT 签名方式。
