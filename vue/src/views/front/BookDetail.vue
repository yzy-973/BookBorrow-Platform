<script setup>


import {useRoute, useRouter} from "vue-router";
import {onMounted, ref, computed} from "vue";
import request from "@/utils/request.js";
import {Star,StarFilled,ChatDotRound,Promotion} from "@element-plus/icons-vue";
import {ElMessage} from "element-plus";

const route=useRoute()
const router=useRouter()

const goods=ref({})
const id=route.query.id
const load=()=>{
  request.get("/book/"+id).then(res=>{
    goods.value=res.data || {}
    const list = goods.value.imgList || ''
    goods.value.imgList = goods.value.img + (list ? ',' + list : '')
  })
}

const currentRoomImg=ref('')
const changeImg=(img)=>{
  goods.value.img=img
}

// 获取表格中显示的图片列表
const getImageList=(imgString)=>{
  if (!imgString)
    return [];
  return imgString.split(',');
};

const users=ref([]);
const loadUser=()=>{
  request.get('/user/simple').then(res=>{
    users.value=res.data
  });
};

/** 跳转确认借阅页 */
const goBorrow=(id)=>{
  if (!account.value.id){
    ElMessage.warning("请登录");
    return;
  }
  router.push(`/front/confirm?id=${id}`);
};

const storedAccount=localStorage.getItem('account')
const account=ref(storedAccount?JSON.parse(storedAccount):{})
const collect=(bookId)=>{
  if (!account.value.id){
    ElMessage.warning("请登录")
    return;
  }
  let data={
    bookId:bookId,
    itemId:bookId,
    userId:account.value.id
  }
  request.post("/collect",data).then(res=>{
    if (res.code==='200'){
      const collected = res.data?.collected !== false
      goods.value.isCollected = collected
      if (typeof res.data?.count === 'number') {
        goods.value.favoriteCount = res.data.count
      } else if (collected) {
        goods.value.favoriteCount = (goods.value.favoriteCount || 0) + 1
      } else {
        goods.value.favoriteCount = Math.max(0, (goods.value.favoriteCount || 1) - 1)
      }
      ElMessage.success(collected ? "收藏成功" : "已取消收藏")
    } else {
      ElMessage.error(res.msg || '操作失败')
    }
  })
}

const recommendBook=()=>{
  if (!account.value.id){
    ElMessage.warning("请登录")
    return
  }
  request.post('/bookRecommend', { bookId: goods.value.id, itemId: goods.value.id }).then(res=>{
    if (res.code === '200') {
      const recommended = res.data?.recommended !== false
      goods.value.isRecommended = recommended
      if (typeof res.data?.count === 'number') {
        goods.value.recommendCount = res.data.count
      } else if (recommended) {
        goods.value.recommendCount = (goods.value.recommendCount || 0) + 1
      } else {
        goods.value.recommendCount = Math.max(0, (goods.value.recommendCount || 1) - 1)
      }
      ElMessage.success(recommended ? '推荐成功' : '已取消推荐')
    } else {
      ElMessage.error(res.msg || '操作失败')
    }
  })
}

const ratings=ref([])
const form=ref({score: 5, comment: ''})
const submitting=ref(false)

const avgScore=computed(()=>{
  if (goods.value.avgRating != null) {
    return Number(goods.value.avgRating)
  }
  if (!ratings.value.length) return 0
  return ratings.value.reduce((s, r) => s + (r.score || 0), 0) / ratings.value.length
})

const loadRatings=()=>{
  request.get('/rating/book/' + id).then(res=>{
    if (res.code === '200') {
      ratings.value = res.data || []
    }
  })
  if (account.value.id) {
    request.get('/rating/mine/' + id).then(res=>{
      if (res.code === '200' && res.data) {
        form.value.score = res.data.score
        form.value.comment = res.data.comment || ''
      }
    })
  }
  // 借阅完成后的评价
  request.get('/borrow/comments/' + id).then(res=>{
    if (res.code === '200') {
      borrowComments.value = res.data || []
    }
  })
}

const borrowComments=ref([])


const submitRating=()=>{
  if (!account.value.id) {
    ElMessage.warning('请先登录')
    return
  }
  if (!form.value.score) {
    ElMessage.warning('请选择星级')
    return
  }
  if (!form.value.comment || !form.value.comment.trim()) {
    ElMessage.warning('请填写评价内容')
    return
  }
  submitting.value = true
  request.post('/rating', {
    bookId: Number(id),
    score: form.value.score,
    comment: form.value.comment.trim()
  }).then(res=>{
    if (res.code === '200') {
      ElMessage.success('评价成功')
      loadRatings()
      load()
    } else {
      ElMessage.error(res.msg || '评价失败')
    }
  }).finally(()=>{
    submitting.value = false
  })
}

const formatTime=(t)=>{
  if (!t) return ''
  return String(t).replace('T', ' ').slice(0, 16)
}

onMounted(()=>{
  load()
  loadUser()
  loadRatings()
})
</script>

<template>
  <div class="goods-detail">
    <div class="seller-header">
      <div class="seller-info" @click="router.push('/front/user?id='+goods.userId)">
        <el-avatar :src="users.find(i=>i.id===goods.userId)?.avatarUrl" :size="50"/>
        <div class="seller-details">
          <h3>{{users.find(i=>i.id===goods.userId)?.nickname}}</h3>
          <div class="seller-stats">
            <span>{{goods.place}}</span>
          </div>
        </div>
      </div>
    </div>

    <div class="main-content">
      <div class="image-section">
        <div class="thumbnail-list">
          <div v-for="(img,index) in getImageList(goods.imgList)"
               :key="index"
               class="thumbnail"
               :class="{active:currentRoomImg===img}"
               @click="changeImg(img)">
            <img :src="img" :alt="`Thumbnail ${index+1}`" width="80" height="80">
          </div>
        </div>
        <div class="main-image">
          <el-image :src="goods.img"/>
          <div v-if="goods.status==='已借出'" class="sold-overlay">
            <div class="sold-badge">
              <img src="../../assets/已借出.png" alt="已借出"/>
            </div>
          </div>
        </div>
      </div>

      <div class="product-info">
        <div class="quality-badge">{{goods.shipment}}</div>
        <div class="price-section">
          <div class="current-price">
            <span class="currency">￥</span>
            <span class="amount">{{goods.price}}</span>
            <span class="shipment">
              <el-text tag="del">原价￥{{goods.rePrice}}</el-text>
            </span>
          </div>

          <div class="view-stats">
            {{ goods.viewCount || 0 }}浏览 · 收藏 {{ goods.favoriteCount || 0 }} · 推荐 {{ goods.recommendCount || 0 }}
          </div>
        </div>
        <h3>{{goods.name}}</h3>
        <div class="product-title" v-html="goods.content"></div>

        <div class="product-specs">
          <div class="spec-item">
            <span class="label">地区:</span>
            <span class="value">{{goods.place}}</span>
          </div>
          <div class="spec-item">
            <span class="label">成色:</span>
            <span class="value">{{goods.quality}}</span>
          </div>
        </div>

        <div class="action-buttons" v-if="account.id!==goods.userId">
          <el-button
              class="favorite-button"
              size="large"
              @click="collect(goods.id)"
              v-if="goods.status==='可借阅'"
          >
            <el-icon>
              <StarFilled v-if="goods.isCollected"/>
              <Star v-else/>
            </el-icon>
            {{ goods.isCollected ? '已收藏' : '收藏' }}
          </el-button>
          <el-button class="chat-button" size="large" @click="router.push('/front/chat?userId='+goods.userId)" v-if="goods.status==='可借阅'">
            <el-icon><ChatDotRound/></el-icon>
            聊一聊
          </el-button>
          <el-button class="buy-button" size="large" type="primary" @click="goBorrow(goods.id)" v-if="goods.status==='可借阅'">
            立即借阅
          </el-button>
          <el-button
              class="recommend-button"
              size="large"
              :class="{ active: goods.isRecommended }"
              @click="recommendBook"
              v-if="goods.status==='可借阅' || goods.status==='已借出'"
          >
            <el-icon><Promotion /></el-icon>
            {{ goods.isRecommended ? '已推荐' : '推荐' }}
          </el-button>
          <el-button
              size="large"
              type="info"
              v-if="goods.status==='已借出'"
              disabled
          >
            已借出
          </el-button>
        </div>
      </div>
    </div>

    <div class="comment-section">
      <div class="comment-header">
        <h3>读者评价</h3>
        <div class="avg-score" v-if="ratings.length || avgScore">
          <el-rate :model-value="Number(avgScore)" disabled show-score score-template="{value} 分" />
          <span class="count">共 {{ ratings.length }} 条评价</span>
        </div>
      </div>

      <div class="comment-form" v-if="account.id && account.id !== goods.userId">
        <div class="form-row">
          <span class="label">我的评分</span>
          <el-rate v-model="form.score" />
        </div>
        <el-input
            v-model="form.comment"
            type="textarea"
            :rows="3"
            maxlength="500"
            show-word-limit
            placeholder="写下你对这本书的评价..."
        />
        <div class="form-actions">
          <el-button type="primary" :loading="submitting" @click="submitRating">提交评价</el-button>
        </div>
      </div>
      <div class="comment-tip" v-else-if="!account.id">
        登录后可发表星级评价
      </div>

      <div v-if="ratings.length === 0 && borrowComments.length === 0" class="comment-empty">暂无评价，来写第一条吧</div>
      <div v-else class="comment-list">
        <div v-for="item in ratings" :key="'r'+item.id" class="comment-item">
          <el-avatar :size="40" :src="item.avatarUrl"/>
          <div class="comment-body">
            <div class="comment-meta">
              <span class="name">{{ item.nickname || '读者' }}</span>
              <el-rate :model-value="item.score" disabled size="small"/>
              <span class="time">{{ formatTime(item.createTime) }}</span>
            </div>
            <p class="comment-text">{{ item.comment }}</p>
          </div>
        </div>
        <div v-for="item in borrowComments" :key="'b'+item.id" class="comment-item">
          <el-avatar :size="40" :src="users.find(u=>u.id===item.toUserId)?.avatarUrl"/>
          <div class="comment-body">
            <div class="comment-meta">
              <span class="name">{{ users.find(u=>u.id===item.toUserId)?.nickname || '借阅者' }}</span>
              <el-rate :model-value="item.borrowerRating" disabled size="small"/>
              <span class="time">{{ formatTime(item.updateTime || item.createTime) }}</span>
              <el-tag size="small" type="info">借阅评价</el-tag>
            </div>
            <p class="comment-text">{{ item.borrowerReview }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.goods-detail{
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
  background: #f5f5f5;
}

.seller-header{
  background: white;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 20px;
}

.seller-info{
  display: flex;
  align-items: center;
  gap: 15px;
  cursor: pointer;
}

.seller-details{
  margin: 0 0 8px 0;
  font-size: 18px;
  font-weight: 600;
  color: #333;
}

.seller-stats{
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #666;
}

.seller-stats .divider{
  color: #ddd;
}

.main-content{
  display: flex;
  gap: 20px;
  align-items: flex-start;
}

.image-section{
  flex: 1;
  display: flex;
  gap: 10px;
  background: white;
  padding: 20px;
  border-radius: 8px;
}

.thumbnail-list{
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.thumbnail{
  width: 80px;
  height: 80px;
  border: 2px solid transparent;
  border-radius: 8px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s;
}

.thumbnail:hover,
.thumbnail.active{
  border-color: #ff6f00;
}

.thumbnail img{
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.main-image{
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fafafa;
  border-radius: 8px;
  overflow: hidden;
  max-height: 600px;
  position: relative;
}

.main-image img{
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
}

.sold-overlay{
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(150, 147, 147, 0.6);
  z-index: 1;
  pointer-events: none;
}

.sold-badge{
  position: absolute;
  top: 30%;
  left: 30%;
  width: 160px;
  height: 160px;
  z-index: 1;
  pointer-events: none;
}

.sold-badge img{
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.product-info{
  width: 500px;
  background: white;
  padding: 30px;
  border-radius: 8px;
  position: relative;
}

.quality-badge{
  position: absolute;
  top: 20px;
  right: 20px;
  background: #fff3e0;
  color: #ff6f00;
  padding: 6px 16px;
  border-radius: 4px;
  font-size: 14px;
  font-weight: 600;
}

.price-section{
  margin-bottom: 20px;
  padding-bottom: 20px;
  border-bottom: 1px solid #f0f0f0;
}

.current-price{
  display: flex;
  align-items: baseline;
  gap: 8px;
  margin-bottom: 8px;
}

.current-price .currency{
  color: #ff6f00;
  font-size: 24px;
  font-weight: 600;
}

.current-price .amount{
  color: #ff6f00;
  font-size: 48px;
  font-weight: 700;
  line-height: 1;
}

.current-price .shipment{
  color: #ff6f00;
  font-size: 16px;
  padding: 4px 8px;
  background: #fff3e0;
  border-radius: 4px;
}

.view-stats{
  color: #999;
  font-size: 13px;
}

.product-title{
  font-size: 16px;
  line-height: 1.6;
  color:#333;
  margin-bottom: 20px;
  padding-bottom: 20px;
  border-bottom: 1px solid #f0f0f0;
}

.product-specs{
  margin-bottom: 30px;
}

.spec-item{
  display: flex;
  padding: 12px 0;
  border-bottom: 1px solid #f5f5f5;
}

.spec-item .label{
  color: #999;
  width: 100px;
  font-size: 14px;
}

.spec-item .value{
  color: #333;
  font-size: 14px;
  flex: 1;
}

/* Action Buttons */
.action-buttons{
  display: flex;
  gap: 10px;
}

.chat-button{
  flex: 1;
  background: #409eff;
  border: none;
  color: #fff;
  font-size: 16px;
  font-weight: 600;
  height: 50px;
}

.chat-button:hover{
  background: #337ecc;
}

.buy-button{
  flex: 1;
  background: #424242;
  border: none;
  color: white;
  font-size: 16px;
  font-weight: 600;
  height: 50px;
}

.buy-button:hover{
  background: #303030;
}

.favorite-button{
  width: 70px;
  height: 50px;
  border: 1px solid #ddd;
  background: white;
  color: #666;
}

.favorite-button.active{
  color: #ff6f00;
  border-color: #ff6f00;
}

.favorite-button:hover{
  border-color: #ff6f00;
  color: #ff6f00;
}

.recommend-button{
  width: 70px;
  height: 50px;
  border: 1px solid #ddd;
  background: white;
  color: #666;
}

.recommend-button.active,
.recommend-button:hover{
  color: #409eff;
  border-color: #409eff;
}

.comment-section{
  margin-top: 20px;
  background: #fff;
  border-radius: 8px;
  padding: 24px;
}

.comment-header{
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.comment-header h3{
  margin: 0;
  font-size: 18px;
  color: #303133;
}

.avg-score{
  display: flex;
  align-items: center;
  gap: 12px;
}

.avg-score .count{
  color: #909399;
  font-size: 13px;
}

.comment-form{
  background: #f7f9fc;
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 20px;
}

.form-row{
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.form-row .label{
  color: #606266;
  font-size: 14px;
}

.form-actions{
  margin-top: 12px;
  text-align: right;
}

.comment-tip,
.comment-empty{
  color: #909399;
  font-size: 14px;
  padding: 12px 0 20px;
}

.comment-list{
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.comment-item{
  display: flex;
  gap: 12px;
  padding-bottom: 16px;
  border-bottom: 1px solid #f0f2f5;
}

.comment-item:last-child{
  border-bottom: none;
  padding-bottom: 0;
}

.comment-body{
  flex: 1;
  min-width: 0;
}

.comment-meta{
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
  margin-bottom: 6px;
}

.comment-meta .nickname,
.comment-meta .name{
  font-weight: 600;
  color: #303133;
  font-size: 14px;
}

.comment-meta .time{
  color: #c0c4cc;
  font-size: 12px;
  margin-left: auto;
}

.comment-text{
  margin: 0;
  color: #606266;
  font-size: 14px;
  line-height: 1.7;
  white-space: pre-wrap;
  word-break: break-word;
}
</style>