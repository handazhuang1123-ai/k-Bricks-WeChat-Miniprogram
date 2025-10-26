# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## ⚠️ 核心约束（违反即为严重错误）

### 1. 配置文件/密钥处理
- 看到文件名包含 `.local`、`.env`、`secret`、`token`、`key`
- 或文件内容包含密钥、token、密码
- **第一反应**：检查是否应在 .gitignore 中
- **禁止**：直接删除敏感内容

### 2. 不要编辑编译产物
- 本项目 `.ts` 自动编译为 `.js`，`.scss` 自动编译为 `.wxss`
- **只编辑源文件**（.ts/.scss）
- **不要编辑编译产物**（.js/.wxss）
- 编译产物会在保存源文件时被微信开发者工具自动覆盖

### 3. setData 性能规则
微信小程序 setData 有严格性能限制：
- ❌ 不要在循环/定时器中频繁调用
- ❌ 不要传递超过 1MB 的数据
- ✅ 优先使用路径更新：`this.setData({ "obj.key": value })`
- ✅ 批量更新多个字段

### 4. 架构/技术选型决策
涉及状态管理、UI库、数据存储、性能优化方案时：
- **必须**：列举至少 2 种方案 + 优缺点对比
- **可选**：提示用户使用 `/think` 查看详细分析

---

## 项目概述

K-Bricks Beta V1.0 是一个基于微信小程序原生框架开发的 TypeScript 项目。

**核心技术栈：**
- TypeScript (严格模式)
- SASS 样式预处理
- 微信小程序基础库 v2.32.3
- Glass-Easel 组件框架
- Skyline 渲染引擎

## 开发环境

### 使用微信开发者工具
项目必须在微信开发者工具中打开和开发：
1. 打开微信开发者工具
2. 导入项目，选择项目根目录
3. AppID: `wx89cf88c9dfefb04b`
4. 开发者工具会自动编译 TypeScript 和 SASS

### 编译机制
- `.ts` 文件保存时自动编译为 `.js`
- `.scss` 文件保存时自动编译为 `.wxss`
- 编译配置在 `project.config.json` 中的 `useCompilerPlugins` 字段
- 生产环境会启用 WXML 和 WXSS 压缩

## 项目架构

### 目录结构
```
miniprogram/
├── app.ts              # 应用生命周期和全局配置
├── app.json            # 全局配置（页面路由、窗口样式）
├── pages/              # 页面组件
├── components/         # 可复用组件
└── utils/              # 工具函数
```

### 文件命名约定
每个小程序组件/页面包含 4 个文件：
- `name.ts` - 组件逻辑（TypeScript）
- `name.wxml` - 模板（类 XML 语法）
- `name.json` - 组件配置和依赖声明
- `name.scss` - 样式（SASS）

### 组件系统架构

**页面组件**（全屏）：
- 位于 `miniprogram/pages/`
- 必须在 `app.json` 的 `pages` 数组中注册
- 数组第一项为小程序入口页面
- 使用 `Component()` API 定义（而非传统的 `Page()`）

**自定义组件**：
- 位于 `miniprogram/components/`
- 在父组件的 `.json` 中声明依赖：
  ```json
  {
    "usingComponents": {
      "navigation-bar": "../../components/navigation-bar/navigation-bar"
    }
  }
  ```
- 支持 properties、data、methods、lifetimes 等

**关键特性**：
- 使用 Glass-Easel 组件框架（更现代的组件系统）
- Skyline 渲染引擎已启用（提升性能）
- 按需注入 (`lazyCodeLoading: "requiredComponents"`)
- 自定义导航栏（`navigationStyle: "custom"`）

### 状态管理
- **全局数据**：通过 `app.ts` 中的 `globalData` 对象
  - 访问方式：`const app = getApp<IAppOption>(); app.globalData`
- **持久化存储**：使用 `wx.getStorageSync()` / `wx.setStorageSync()`
- **组件状态**：使用 `this.setData()` 更新数据并触发视图更新
  - 嵌套属性更新：`this.setData({ "userInfo.nickName": value })`

### 页面导航
- 使用 `wx.navigateTo({ url: '../target/page' })` 进行路由跳转
- 返回上一页：`wx.navigateBack({ delta: 1 })`
- 路由在 `app.json` 中配置

## TypeScript 配置

严格模式已启用（`strict: true`），包括：
- `noImplicitAny` - 禁止隐式 any 类型
- `noUnusedLocals` - 未使用的局部变量会报错
- `noUnusedParameters` - 未使用的函数参数会报错
- `strictNullChecks` - 严格的 null 检查

类型定义：
- 微信小程序 API 类型来自 `miniprogram-api-typings`
- 自定义类型放在 `./typings/` 目录

## 组件开发模式

### 组件定义结构
```typescript
Component({
  properties: {        // 父组件传入的属性
    title: { type: String, value: '' },
    show: {
      type: Boolean,
      value: true,
      observer: '_showChange'  // 属性变化监听
    }
  },
  data: {             // 组件内部状态
    displayStyle: ''
  },
  lifetimes: {        // 生命周期
    attached() { }
  },
  methods: {          // 事件处理和自定义方法
    handleClick() {
      this.triggerEvent('custom-event', { data }, {})
    }
  }
})
```

### 常用 API 模式
```typescript
// 页面跳转
wx.navigateTo({ url: '../logs/logs' })

// 用户信息获取（需用户授权）
wx.getUserProfile({
  desc: '用于完善用户资料',
  success: (res) => { }
})

// 获取系统信息（适配不同机型）
wx.getSystemInfo({
  success: (res) => {
    const { platform, safeArea, windowWidth } = res
  }
})

// 全局应用实例
const app = getApp<IAppOption>()
```

## 样式开发

- 所有 `.scss` 文件自动编译为 `.wxss`
- 全局样式在 `app.scss`
- 组件样式默认隔离（isolated）
- **限制**：微信小程序不支持所有 CSS 特性（如 Flexbox 的 `gap` 属性在旧版本中不支持）

## UI 组件库

### TDesign 微信小程序（推荐）

项目推荐使用 **TDesign** 作为 UI 组件库，这是腾讯开源的企业级设计体系。

**为什么选择 TDesign：**
- 腾讯官方企业级解决方案，由近 300 名设计师与开发者共同打造
- 经过 500+ 个项目验证和锤炼，稳定可靠
- 完美匹配项目的 TypeScript + SASS 技术栈
- 提供统一的设计语言和视觉风格
- 组件 API 设计规范，文档完善

**官方资源：**
- 官网：https://tdesign.tencent.com/
- 小程序文档：https://tdesign.tencent.com/miniprogram/overview
- 快速开始：https://tdesign.tencent.com/miniprogram/getting-started
- 组件演示：https://tdesign.tencent.com/miniprogram/components/button
- 设计资源：https://tdesign.tencent.com/source

**安装方式：**
```bash
npm install tdesign-miniprogram --save
```

**在组件中使用：**
```json
{
  "usingComponents": {
    "t-button": "tdesign-miniprogram/button/button",
    "t-cell": "tdesign-miniprogram/cell/cell"
  }
}
```

**备选方案：**
- **WeUI**：微信官方 UI 库，提供原生视觉体验，支持扩展库引入（不占包体积）
- **Vant Weapp**：有赞团队开发，组件丰富，社区活跃

## 调试

1. **模拟器**：微信开发者工具内置
2. **真机调试**：工具栏 -> 预览/真机调试
3. **控制台**：`console.log()` 输出到开发者工具控制台
4. **Source Maps**：已启用（`uploadWithSourceMap: true`）
5. **性能分析**：开发者工具 -> 性能面板

## 关键配置说明

### app.json 重要字段
- `pages`：页面路由列表（第一项为首页）
- `componentFramework: "glass-easel"`：使用新版组件框架
- `rendererOptions.skyline`：Skyline 渲染配置
- `lazyCodeLoading`：代码按需注入策略

### project.config.json 编译选项
- `useCompilerPlugins: ["typescript", "sass"]`：启用 TS 和 SASS 编译
- `skylineRenderEnable: true`：启用 Skyline 渲染
- `minifyWXML`/`minifyWXSS`：生产环境压缩

## 适配注意事项

### 自定义导航栏适配
当前项目使用自定义导航栏（见 `components/navigation-bar`）：
- 需要获取胶囊按钮位置：`wx.getMenuButtonBoundingClientRect()`
- 需要获取安全区域：`wx.getSystemInfo()` 中的 `safeArea`
- iOS 和 Android 适配逻辑不同（见 navigation-bar 组件实现）

### 跨平台兼容性
- 使用 `wx.canIUse()` 检查 API 可用性
- 示例：`wx.canIUse('getUserProfile')` 检查新版用户信息 API
