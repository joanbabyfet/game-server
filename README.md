# 老虎机游戏服务器（Slot Game Server）

基于 Skynet + Lua 开发的轻量级老虎机（Slot）游戏服务器，适用于 Casino / iGaming 平台接入。

## 项目特点

* 基于 Skynet 的高并发 Slot 游戏服务器
* Reel Strip + Payline 数学模型
* Wild、Scatter、Free Spin 支持
* Jackpot 奖池（Redis）
* Wallet 钱包（Redis）
* Config Manager 配置中心
* Request ID 幂等控制
* Round / 注单 管理
* Redis 缓存 + MySQL 持久化架构
* 金额最小单位设计（避免浮点误差）
* 自动配置热更新
* 完整自动化测试
* 模块化游戏配置，支持多游戏扩展

## 技术栈

* Lua
* Skynet
* MySQL
* Redis

## 项目目录

```text
config/     游戏配置
logic/      游戏逻辑 (暂不公开)
model/      数据模型
service/    服务模块
common/     公共组件
sql/        初始化 SQL 文件
```

## 快速启动

```bash
./run.sh
./run_test.sh
```

## 项目目标

本项目采用配置化设计，将 **PayTable、Reel、Payline、Bonus、Jackpot** 等数学模型与游戏逻辑分离，便于后续扩展多款 Slot 游戏，支持接入第三方 Casino 平台。

## License

MIT