// app.js
// 引入配置文件
const publicConfig = require('./config/index.js')
const privateConfig = require('./config/private.js')

// 合并公开和私有配置（私有配置优先）
const config = { ...publicConfig, ...privateConfig }

App({
  onLaunch: function () {
    // ====== 配置加载验证（开发阶段） ======
    console.log('【配置验证】公开配置:', publicConfig);
    console.log('【配置验证】私有配置:', privateConfig);
    console.log('【配置验证】合并后配置:', config);
    console.log('【配置验证】云环境 ID:', config.cloudEnvId);
    // =====================================

    // 初始化云开发
    if (!wx.cloud) {
      console.error("请使用 2.2.3 或以上的基础库以使用云能力");
    } else {
      wx.cloud.init({
        env: config.cloudEnvId,
        traceUser: true,
      });
      console.log('【云开发】初始化成功，环境 ID:', config.cloudEnvId);
    }
  },

  // 全局配置可通过 getApp().config 访问
  config: config,

  globalData: {
    // 全局数据
  }
});
