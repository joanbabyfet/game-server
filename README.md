# 老虎机游戏服务器（Slot Game Server）

基于 Skynet + Lua 开发的轻量级老虎机（Slot）游戏服务器，适用于 Casino / iGaming 平台接入。

## 项目特点

* 老虎机 Spin 游戏逻辑
* Jackpot 奖池
* Free Spin 免费旋转
* Bonus Game 奖励游戏
* RTP 统计
* 游戏配置管理
* 回合（Round）管理
* 注单（Order）管理
* 幂等（Request ID）
* Rollback 回滚支持
* 钱包（Wallet）管理

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