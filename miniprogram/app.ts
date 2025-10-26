// app.ts
import publicConfig from './config/index'
import privateConfig from './config/private'

// 合并公开和私有配置（私有配置优先）
const config = { ...publicConfig, ...privateConfig }

App<IAppOption>({
  globalData: {},

  // 全局配置可通过 getApp().config 访问
  config: config,

  onLaunch() {
    // 展示本地存储能力
    const logs = wx.getStorageSync('logs') || []
    logs.unshift(Date.now())
    wx.setStorageSync('logs', logs)

    // 初始化云开发
    if (!wx.cloud) {
      console.error('请使用 2.2.3 或以上的基础库以使用云能力')
    } else {
      wx.cloud.init({
        env: config.cloudEnvId,
        traceUser: true,
      })
    }

    // 登录
    wx.login({
      success: res => {
        console.log(res.code)
        // 发送 res.code 到后台换取 openId, sessionKey, unionId
      },
    })
  },
})