<script setup>
import {useRouter} from "vue-router";
import request from "@/utils/request.js";
import {ref, onMounted} from "vue";
import {ElMessage, ElMessageBox} from "element-plus";
import {Promotion, ChatDotSquare, ShoppingCart} from "@element-plus/icons-vue";

const router = useRouter()
const books = ref([])
const keyword = ref('')
const pageNum = ref(1)
const pageSize = ref(12)
const total = ref(0)
const loading = ref(false)

const load = () => {
  loading.value = true
  request.get('/recommend/my', {
    params: {keyword: keyword.value}
  }).then(res => {
    if (res.code === '200') {
      const list = res.data || []
      total.value = list.length
      const start = (pageNum.value - 1) * pageSize.value
      books.value = list.slice(start, start + pageSize.value)
    }
  }).finally(() => {
    loading.value = false
  })
}

const reset = () => {
  keyword.value = ''
  pageNum.value = 1
  load()
}

const handleSizeChange = (newPageSize) => {
  pageSize.value = newPageSize
  pageNum.value = 1
  load()
}

const handleCurrentChange = (newPageNum) => {
  pageNum.value = newPageNum
  load()
}

const cancelRecommend = (item) => {
  ElMessageBox.confirm('确定取消推荐该图书？', '提示', {type: 'warning'}).then(() => {
    request.delete('/recommend/book/' + item.id).then(res => {
      if (res.code === '200') {
        ElMessage.success('已取消推荐')
        load()
      }
    })
  }).catch(() => {})
}

onMounted(() => {
  load()
})
</script>

<template>
  <div class="recommend-page" v-loading="loading">
    <div class="header">
      <h2>我的推荐</h2>
    </div>
    <div style="margin: 10px 0">
      <el-input style="width: 400px" placeholder="输入图书名称进行搜索" v-model="keyword"></el-input>
      <el-button style="margin-left: 5px" type="primary" plain @click="load">搜索</el-button>
      <el-button type="info" plain @click="reset">重置</el-button>
    </div>
    <el-divider></el-divider>
    <div v-if="books.length===0" class="empty">
      <p>暂无推荐图书</p>
    </div>

    <div v-else class="goods-grid">
      <div v-for="item in books" :key="item.id" class="goods-card">
        <div class="image-container">
          <img :src="item.img||'/placeholder.svg?height=200&width=200'" :alt="item.name"/>
          <div v-if="item.status==='已借出'" class="sold-overlay">
            <div class="sold-badge">
              <img src="../../assets/已借出.png" alt="已借出"/>
            </div>
          </div>
          <div class="hover-actions">
            <button class="action-btn uncollect" @click.stop="cancelRecommend(item)">
              <el-icon><Promotion/></el-icon>
              取消推荐
            </button>
            <button
                v-if="item.status !=='已借出'"
                class="action-btn borrow"
                @click.stop="router.push('/front/confirm?id='+item.id)"
            >
              <el-icon><ShoppingCart/></el-icon>
              我想借
            </button>
            <button
                class="action-btn chat"
                @click.stop="router.push('/front/chat?userId='+item.userId)"
            >
              <el-icon><ChatDotSquare/></el-icon>
              聊一聊
            </button>
          </div>
        </div>

        <div class="goods-info" @click="router.push('/front/bookDetail?id='+item.id)">
          <div class="goods-name">{{item.name||'图书名称'}}</div>
          <div class="price-section">
            <span class="current-price">￥{{item.price||0}}/30天</span>
          </div>
        </div>
      </div>
    </div>

    <div class="pagination-wrapper">
      <el-pagination
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
          :current-page="pageNum"
          :page-sizes="[4, 8, 12, 16]"
          :page-size="pageSize"
          layout="total,sizes,prev,pager,next,jumper"
          :total="total"
      />
    </div>
  </div>
</template>

<style scoped>
.recommend-page {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.header {
  margin-bottom: 24px;
}

.header h2 {
  font-size: 24px;
  font-weight: 600;
  color: #333;
}

.empty {
  text-align: center;
  padding: 60px 20px;
  color: #999;
  font-size: 16px;
}

.goods-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 16px;
}

.goods-card {
  background: white;
  border-radius: 8px;
  overflow: hidden;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.goods-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
}

.image-container {
  position: relative;
  width: 100%;
  padding-top: 100%;
  overflow: hidden;
  background: #f5f5f5;
}

.image-container img {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.sold-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(150, 147, 147, 0.6);
  z-index: 1;
  pointer-events: none;
}

.sold-badge {
  position: absolute;
  top: 30%;
  left: 30%;
  width: 130px;
  height: 130px;
  z-index: 1;
  pointer-events: none;
}

.sold-badge img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.hover-actions {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  gap: 0;
  opacity: 0;
  transform: translateY(10px);
  transition: all 0.3s ease;
  z-index: 2;
}

.goods-card:hover .hover-actions {
  opacity: 1;
  transform: translateY(0);
}

.action-btn {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
  padding: 10px 4px;
  border: none;
  font-size: 12px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  background: rgba(0, 0, 0, 0.35);
  color: white;
  backdrop-filter: blur(8px);
}

.action-btn:hover {
  background: rgba(0, 0, 0, 0.55);
}

.action-btn.uncollect svg {
  fill: currentColor;
}

.action-btn.borrow,
.action-btn.chat {
  border-left: 1px solid rgba(255, 255, 255, 0.2);
}

.goods-info {
  padding: 12px;
  cursor: pointer;
}

.goods-name {
  font-size: 14px;
  color: #333;
  margin-bottom: 8px;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  line-height: 1.4;
  min-height: 40px;
}

.price-section {
  display: flex;
  align-items: center;
  gap: 8px;
}

.current-price {
  font-size: 18px;
  font-weight: 600;
  color: #ff4d4f;
}

.pagination-wrapper {
  display: flex;
  justify-content: center;
  padding: 32px 0;
}
</style>
