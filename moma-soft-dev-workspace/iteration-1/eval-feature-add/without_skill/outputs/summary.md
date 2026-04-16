# 拼团购买功能新增 — 变更总结

## 变更概述

在校园二手交易平台基础上新增"拼团购买"功能，允许多个用户一起拼团购买同一商品以获得折扣价。

## 产出文件

| 文件 | 说明 |
|------|------|
| `docs/02-产品需求文档.md` | 新增拼团购买功能模块的完整需求定义，包括用户故事、功能流程、验收条件、业务规则、界面需求 |
| `docs/04-数据模型文档.md` | 新增 3 张数据表设计（group_buy_activity、group_buy_team、group_buy_member），含完整字段定义、索引、ER图和迁移SQL |
| `docs/05-API接口文档.md` | 新增 9 个拼团相关 RESTful API 接口定义，含请求/响应示例和错误码 |
| `docs/08-变更日志.md` | 记录 CR-001 变更条目及 V1.1 版本发布记录 |

## 功能要点

1. **卖家创建拼团活动**：为商品设置拼团价格（< 原价）、目标人数（2-10人）、有效期（1-72小时）、库存
2. **买家发起/参与拼团**：发起新团（成为团长）或加入现有团，支付拼团价
3. **自动成团/失败处理**：人数达标自动成团；超时未满自动取消并退款
4. **拼团进度展示**：实时显示当前人数/目标人数、剩余时间倒计时
5. **拼团分享**：生成分享链接，邀请同学参团
6. **我的拼团**：用户中心查看参与的所有拼团记录

## 新增数据表

- `group_buy_activity` — 拼团活动表（卖家创建的活动定义）
- `group_buy_team` — 拼团单表（每次具体的拼团实例）
- `group_buy_member` — 拼团成员表（参与者记录）

## 新增 API 接口（9个）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | /api/v1/group-buy/activities | 创建拼团活动 |
| GET | /api/v1/group-buy/activities | 查询拼团活动列表 |
| GET | /api/v1/group-buy/activities/{id} | 查询拼团活动详情 |
| PUT | /api/v1/group-buy/activities/{id}/cancel | 取消拼团活动 |
| POST | /api/v1/group-buy/teams | 发起拼团 |
| POST | /api/v1/group-buy/teams/{id}/join | 参与拼团 |
| GET | /api/v1/group-buy/teams/{id} | 查询拼团单详情 |
| GET | /api/v1/group-buy/activities/{id}/teams | 查询活动下拼团列表 |
| GET | /api/v1/group-buy/my-teams | 我的拼团列表 |

## 关键业务规则

- 同一商品同时只能有一个进行中的拼团活动
- 同一用户不能重复参与同一拼团
- 拼团成功后不可取消拼团（走正常退货流程）
- 拼团失败后 24 小时内完成退款
