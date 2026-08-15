<script setup>
import {ref, reactive} from 'vue'
import {useRouter} from 'vue-router'
import {projectName} from '@config/config.default'
import {User, Lock, Reading, Notebook, Clock, Collection, ChatDotRound} from '@element-plus/icons-vue'
import {ElMessage} from 'element-plus'
import request from '@/utils/request.js'
import logoUrl from '@config/brand-logo-blue.png'

const router = useRouter()
const userFormInst = ref(null)
const roleOptions = [
  {label: '普通用户', value: 'ROLE_USER'},
  {label: '管理员', value: 'ROLE_ADMIN'},
]
const account = reactive({username: '', password: '', role: 'ROLE_USER'})
const rules = {
  username: [{required: true, message: '请输入用户名', trigger: 'blur'}, {min: 3, max: 10, message: '长度在 3 到 10 个字符', trigger: 'blur'}],
  password: [{required: true, message: '请输入密码', trigger: 'blur'}, {min: 1, max: 20, message: '长度在 1 到 20 个字符', trigger: 'blur'}],
  role: [{required: true, message: '请选择角色', trigger: 'change'}]
}
const chips = ['馆藏检索', '在线借阅', '续借管理', '逾期提醒', '留言互动']
const floats = [
  { icon: Notebook, text: '今日借阅 127' },
  { icon: Collection, text: '热门图书 Top50' },
  { icon: Reading, text: '馆藏 8,562 册' },
  { icon: Clock, text: '归还提醒 3' },
]
const login = () => {
  userFormInst.value.validate((valid) => {
    if (!valid) return
    request.post('/web/login', account).then((res) => {
      if (res.code === '200') {
        localStorage.setItem('account', JSON.stringify(res.data))
        router.push(res.data.role === 'ROLE_ADMIN' ? '/back/home' : '/front/home')
        ElMessage.success('登录成功')
      } else ElMessage.error(res.msg || '登录失败')
    })
  })
}
</script>

<template>
  <div class="page-i">
    <div class="blob-layer" aria-hidden="true">
      <span class="blob b1"></span>
      <span class="blob b2"></span>
      <span class="blob b3"></span>
      <span class="blob b4"></span>
    </div>

    <div class="layout">
      <section class="hero">
        <!-- 浮标环绕品牌文案外围，不压标题 -->
        <div class="floats" aria-hidden="true">
          <div
              v-for="(f, i) in floats"
              :key="i"
              class="float"
              :class="'float-' + (i + 1)"
              :style="{ '--i': i }"
          >
            <el-icon><component :is="f.icon" /></el-icon>
            <span>{{ f.text }}</span>
          </div>
        </div>
        <div class="hero-core">
          <div class="logo-sq"><img :src="logoUrl" alt="logo" /></div>
          <h1>{{ projectName }}</h1>
          <p class="sub">智慧图书共享服务平台</p>
          <p class="feats">馆藏查询 · 高效借阅 · 归还提醒 · 留言反馈</p>
          <div class="chips">
            <span v-for="c in chips" :key="c">{{ c }}</span>
          </div>
        </div>
      </section>

      <aside class="card">
        <span class="pill">图书共享统一入口</span>
        <h2>统一身份登录</h2>
        <p class="hint">请使用账号登录系统</p>
        <el-form ref="userFormInst" :model="account" :rules="rules" size="large" label-position="top">
          <el-form-item label="用户名" prop="username">
            <el-input v-model="account.username" placeholder="请输入用户名" :prefix-icon="User" class="glow-input" />
          </el-form-item>
          <el-form-item label="密码" prop="password">
            <el-input v-model="account.password" type="password" show-password placeholder="请输入密码" :prefix-icon="Lock" class="glow-input" />
          </el-form-item>
          <el-form-item label="角色" prop="role" class="role-item">
            <el-radio-group v-model="account.role">
              <el-radio-button v-for="r in roleOptions" :key="r.value" :value="r.value">{{ r.label }}</el-radio-button>
            </el-radio-group>
          </el-form-item>
          <el-button type="primary" class="submit" @click="login">
            <span class="submit-text">登录系统</span>
          </el-button>
        </el-form>
        <p class="links">
          <router-link to="/register">注册账号</router-link>
        </p>
        <p class="note"><el-icon><ChatDotRound /></el-icon> 新注册账号可立即登录使用</p>
      </aside>
    </div>
  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@400;600;700&display=swap');

.page-i {
  --blue: #409eff;
  --mid: #66b1ff;
  --soft: #79bbff;
  --deep: #1a5c9e;
  --ink: #1e3a5f;
  --muted: #6b7c93;
  --radius-lg: 24px;
  --radius-md: 16px;
  --radius-sm: 12px;
  --shadow-1: 0 8px 20px rgba(26, 92, 158, .08);
  --shadow-2: 0 16px 40px rgba(26, 92, 158, .12);
  --shadow-3: 0 28px 64px rgba(26, 92, 158, .18);

  min-height: 100vh;
  min-height: 100dvh;
  padding: clamp(16px, 4vw, 40px) clamp(14px, 3vw, 28px);
  position: relative;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(145deg, #eef6ff 0%, #f7fbff 42%, #e3f0ff 100%);
  font-family: 'Noto Sans SC', sans-serif;
  color: var(--ink);
  box-sizing: border-box;
}

/* —— 流体 blob —— */
.blob-layer {
  position: absolute;
  inset: -10%;
  pointer-events: none;
  z-index: 0;
}
.blob {
  position: absolute;
  border-radius: 42% 58% 55% 45% / 48% 42% 58% 52%;
  filter: blur(48px);
  opacity: .5;
  will-change: transform, border-radius;
}
.b1 {
  width: min(420px, 55vw); height: min(420px, 55vw);
  background: radial-gradient(circle at 30% 30%, #c6e2ff, #79bbff 55%, transparent 70%);
  top: -8%; left: -6%;
  animation: blobFlow1 18s ease-in-out infinite;
}
.b2 {
  width: min(360px, 48vw); height: min(360px, 48vw);
  background: radial-gradient(circle at 60% 40%, #a0cfff, #409eff 60%, transparent 72%);
  bottom: -12%; right: 6%;
  animation: blobFlow2 22s ease-in-out infinite;
}
.b3 {
  width: min(260px, 38vw); height: min(260px, 38vw);
  background: radial-gradient(circle at 40% 60%, #d9ecff, #66b1ff 50%, transparent 70%);
  top: 28%; right: -5%;
  animation: blobFlow3 16s ease-in-out infinite;
}
.b4 {
  width: min(200px, 30vw); height: min(200px, 30vw);
  background: radial-gradient(circle at 50% 50%, rgba(64,158,255,.45), transparent 70%);
  bottom: 22%; left: 28%;
  opacity: .35;
  animation: blobFlow1 26s ease-in-out infinite reverse;
}
@keyframes blobFlow1 {
  0%, 100% { transform: translate(0, 0) scale(1) rotate(0deg); border-radius: 42% 58% 55% 45% / 48% 42% 58% 52%; }
  33% { transform: translate(4%, 6%) scale(1.08) rotate(8deg); border-radius: 55% 45% 42% 58% / 40% 55% 45% 60%; }
  66% { transform: translate(-3%, 3%) scale(.94) rotate(-6deg); border-radius: 48% 52% 60% 40% / 55% 48% 52% 45%; }
}
@keyframes blobFlow2 {
  0%, 100% { transform: translate(0, 0) scale(1) rotate(0deg); border-radius: 50% 50% 45% 55% / 45% 55% 50% 50%; }
  40% { transform: translate(-5%, -4%) scale(1.1) rotate(-10deg); border-radius: 40% 60% 55% 45% / 55% 40% 60% 45%; }
  70% { transform: translate(3%, -2%) scale(.96) rotate(5deg); border-radius: 58% 42% 48% 52% / 42% 58% 45% 55%; }
}
@keyframes blobFlow3 {
  0%, 100% { transform: translate(0, 0) scale(1); border-radius: 45% 55% 50% 50% / 55% 45% 55% 45%; }
  50% { transform: translate(-6%, 5%) scale(1.12); border-radius: 60% 40% 45% 55% / 40% 60% 40% 60%; }
}

.layout {
  position: relative;
  z-index: 1;
  width: min(1180px, 100%);
  display: grid;
  grid-template-columns: 1.15fr .85fr;
  gap: clamp(28px, 4vw, 56px);
  align-items: center;
}

.hero {
  position: relative;
  min-height: 480px;
  /* 四周留白给浮标，避免压到标题 */
  padding: 48px 140px 90px 56px;
}
.hero-core {
  position: relative;
  z-index: 1;
  max-width: 400px;
}
.logo-sq {
  width: 72px; height: 72px; border-radius: 0;
  display: grid; place-items: center;
  background: transparent;
  box-shadow: none;
  margin-bottom: 20px;
  transition: transform .35s ease;
  overflow: visible;
}
.logo-sq img {
  width: 100%;
  height: 100%;
  object-fit: contain;
  display: block;
}
.logo-sq:hover {
  transform: translateY(-3px) scale(1.04);
}
.hero h1 {
  margin: 0;
  font-size: clamp(28px, 3.4vw, 42px);
  letter-spacing: .04em;
  line-height: 1.25;
  white-space: nowrap;
}
.sub { margin: 12px 0 0; color: var(--blue); font-weight: 700; }
.feats { margin: 14px 0 22px; color: var(--muted); font-size: 14px; }
.chips { display: flex; flex-wrap: wrap; gap: 10px; }
.chips span {
  padding: 10px 16px;
  border-radius: 999px;
  background: rgba(255,255,255,.88);
  box-shadow: var(--shadow-1);
  font-size: 13px;
  color: #337ecc;
  transition: transform .25s ease, box-shadow .25s ease;
}
.chips span:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-2);
}

/* —— 浮标：环绕文案外圈（位置参考优化版） —— */
.floats {
  position: absolute;
  inset: 0;
  pointer-events: none;
  z-index: 2;
}
.float {
  position: absolute;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 14px;
  border-radius: var(--radius-sm);
  background: rgba(255,255,255,.92);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255,255,255,.7);
  font-size: 13px;
  color: var(--deep);
  white-space: nowrap;
  will-change: transform;
  box-shadow: 0 10px 22px rgba(26,92,158,.12);
  opacity: 0;
  animation: floatIn .7s ease forwards, floatBob 5.4s ease-in-out infinite;
  animation-delay: calc(var(--i) * .12s), calc(var(--i) * .12s + .5s);
}
/* 上右 / 右中 / 馆藏贴近逾期提醒右下 / 左下归还提醒 */
.float-1 { top: 0; right: 8px; }
.float-2 { top: 42%; right: -12px; }
.float-3 {
  left: calc(310px + 2.5cm);
  bottom: calc(78px - 1.5cm);
  right: auto;
}
.float-4 { bottom: 8px; left: 8px; }

@keyframes floatIn {
  from { opacity: 0; transform: translateY(20px) scale(.94); }
  to { opacity: 1; transform: translateY(0) scale(1); }
}
@keyframes floatBob {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}

/* —— 登录卡片 —— */
.card {
  background: rgba(255,255,255,.96);
  border-radius: var(--radius-lg);
  padding: 36px 34px 28px;
  box-shadow: var(--shadow-2);
  border: 1px solid rgba(255,255,255,.8);
  transition: transform .35s cubic-bezier(.22,1,.36,1), box-shadow .35s ease;
}
.card:hover {
  transform: translateY(-8px);
  box-shadow: var(--shadow-3);
}
.pill {
  display: inline-block;
  padding: 6px 12px;
  border-radius: 999px;
  font-size: 12px;
  background: #ecf5ff;
  color: var(--blue);
  font-weight: 700;
  margin-bottom: 14px;
}
.card h2 { margin: 0; font-size: clamp(24px, 3vw, 30px); }
.hint { margin: 8px 0 22px; color: var(--muted); font-size: 14px; }
.card :deep(.el-form-item__label) { color: #5a7a9a; font-weight: 600; }

/* 输入框聚焦光影 */
.card :deep(.el-input__wrapper),
.glow-input :deep(.el-input__wrapper) {
  border-radius: var(--radius-sm) !important;
  min-height: 46px;
  background: #f7fbff !important;
  box-shadow: 0 0 0 1px #dceaf8 inset !important;
  transition: box-shadow .28s ease, background .28s ease, transform .28s ease !important;
}
.card :deep(.el-input__wrapper:hover) {
  box-shadow: 0 0 0 1px #b3d8ff inset !important;
}
.card :deep(.el-input__wrapper.is-focus) {
  background: #fff !important;
  box-shadow:
      0 0 0 1px var(--blue) inset,
      0 0 0 4px rgba(64,158,255,.16),
      0 10px 24px rgba(64,158,255,.18) !important;
}

/* 角色：标签左对齐（与用户名/密码一致），选项居中 */
.role-item {
  display: block !important;
  margin-bottom: 18px;
}
.role-item :deep(.el-form-item__label) {
  width: 100% !important;
  max-width: none !important;
  margin: 0 0 8px !important;
  padding: 0 !important;
  float: none !important;
  text-align: left !important;
  justify-content: flex-start !important;
  line-height: 1.5 !important;
}
.role-item :deep(.el-form-item__content) {
  display: flex;
  justify-content: center;
  margin-left: 0 !important;
  width: 100%;
}
.role-item :deep(.el-radio-group) {
  display: inline-flex;
  justify-content: center;
  border-radius: var(--radius-sm);
  overflow: hidden;
  box-shadow: 0 0 0 1px #dceaf8;
}
.role-item :deep(.el-radio-button__inner) {
  border: none !important;
  box-shadow: none !important;
}

/* 渐变按钮 + 扫光 */
.submit {
  position: relative;
  width: 100%;
  height: 50px;
  margin-top: 4px;
  border: none;
  border-radius: var(--radius-md);
  font-weight: 700;
  overflow: hidden;
  color: #fff !important;
  background: linear-gradient(105deg, var(--mid), var(--blue) 45%, var(--deep)) !important;
  box-shadow: 0 14px 28px rgba(64,158,255,.35);
  transition: transform .25s ease, box-shadow .25s ease;
}
.submit::before {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(
      105deg,
      transparent 0%,
      transparent 38%,
      rgba(255,255,255,.45) 50%,
      transparent 62%,
      transparent 100%
  );
  transform: translateX(-120%);
  animation: sheen 3.6s ease-in-out infinite;
}
.submit-text { position: relative; z-index: 1; }
.submit:hover {
  transform: translateY(-2px);
  box-shadow: 0 18px 34px rgba(64,158,255,.42);
}
@keyframes sheen {
  0%, 55% { transform: translateX(-120%); }
  80%, 100% { transform: translateX(120%); }
}

.links { margin-top: 18px; text-align: center; color: #9aa8bc; font-size: 13px; }
.links a { color: var(--blue); text-decoration: none; margin: 0 6px; font-weight: 600; }
.links a:hover { color: var(--deep); }
.note {
  margin: 16px 0 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  font-size: 12px;
  color: #8aa0b8;
}

/* —— 移动端 —— */
@media (max-width: 960px) {
  .page-i { align-items: flex-start; padding-top: 28px; padding-bottom: 40px; }
  .layout {
    grid-template-columns: 1fr;
    gap: 22px;
    width: min(480px, 100%);
  }
  .hero {
    min-height: auto;
    padding: 4px 0 8px;
    text-align: center;
  }
  .hero-core {
    max-width: none;
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  .feats { margin-bottom: 14px; }
  .chips { justify-content: center; }
  .floats { display: none; }
  .card {
    padding: 28px 22px 24px;
    border-radius: 20px;
  }
  .card:hover { transform: translateY(-4px); }
  .b4 { display: none; }
}

@media (max-width: 480px) {
  .hero h1 { font-size: 26px; }
  .chips span { padding: 8px 12px; font-size: 12px; }
  .role-item :deep(.el-radio-button__inner) {
    padding: 8px 12px;
    font-size: 13px;
  }
}

@media (prefers-reduced-motion: reduce) {
  .blob, .float, .submit::before { animation: none !important; }
  .card, .logo-sq, .chips span, .submit { transition: none !important; }
}
</style>

