// 公开配置文件（提交到 Git）
// 包含非敏感的应用配置

export interface AppConfig {
  appName: string
  version: string
  apiTimeout: number
  cloudEnvId: string
}

const config: AppConfig = {
  // 应用基本信息
  appName: 'K-Bricks',
  version: '1.0.0',

  // API 配置
  apiTimeout: 5000,

  // 云开发配置（占位符，会被 private.ts 覆盖）
  cloudEnvId: '',
}

export default config
