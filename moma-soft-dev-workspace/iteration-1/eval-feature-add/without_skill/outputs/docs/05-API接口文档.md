# API 接口文档 — 拼团购买功能新增

> **定位：** 定义拼团购买功能新增的 API 接口契约。
> **变更说明：** 本次新增 9 个拼团相关接口。

---

## 1. 文档信息

| 字段 | 内容 |
|------|------|
| 项目名称 | 校园二手交易平台 |
| 版本 | V1.1 |
| API 基础路径 | /api/v1 |
| 认证方式 | Bearer Token |
| 关联文档 | [产品需求文档](./02-产品需求文档.md)、[数据模型文档](./04-数据模型文档.md) |

---

## 2. 新增接口列表总览

| 模块 | 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|------|
| 拼团活动 | 创建拼团活动 | POST | /api/v1/group-buy/activities | 卖家为商品创建拼团活动 |
| 拼团活动 | 查询拼团活动列表 | GET | /api/v1/group-buy/activities | 获取拼团活动列表 |
| 拼团活动 | 查询拼团活动详情 | GET | /api/v1/group-buy/activities/{activityId} | 获取拼团活动详情 |
| 拼团活动 | 取消拼团活动 | PUT | /api/v1/group-buy/activities/{activityId}/cancel | 卖家取消拼团活动 |
| 拼团单 | 发起拼团 | POST | /api/v1/group-buy/teams | 买家发起新拼团 |
| 拼团单 | 参与拼团 | POST | /api/v1/group-buy/teams/{teamId}/join | 买家参与已有拼团 |
| 拼团单 | 查询拼团单详情 | GET | /api/v1/group-buy/teams/{teamId} | 获取拼团单详情及成员 |
| 拼团单 | 查询活动下拼团列表 | GET | /api/v1/group-buy/activities/{activityId}/teams | 获取某活动下进行中的拼团 |
| 用户拼团 | 我的拼团列表 | GET | /api/v1/group-buy/my-teams | 查询当前用户参与的拼团 |

---

## 3. 接口详细定义

### 3.1 拼团活动管理

#### 3.1.1 创建拼团活动

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `POST /api/v1/group-buy/activities` |
| 接口描述 | 卖家为已发布的商品创建拼团活动 |
| 是否需要认证 | 是 |
| 权限要求 | 商品卖家本人 |

**Body 参数：**

```json
{
  "productId": 10001,
  "groupPrice": 59.90,
  "targetCount": 3,
  "durationHours": 24,
  "stock": 10
}
```

| 参数名 | 类型 | 必填 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| productId | Long | 是 | 必须为用户自己的商品 | 商品ID |
| groupPrice | BigDecimal | 是 | > 0 且 < 商品原价 | 拼团价格 |
| targetCount | Integer | 是 | 2 ≤ x ≤ 10 | 目标拼团人数 |
| durationHours | Integer | 是 | 1 ≤ x ≤ 72 | 拼团有效时长（小时） |
| stock | Integer | 是 | ≥ targetCount | 拼团库存数量 |

**响应示例：**

*成功响应：*

```json
{
  "code": 200,
  "message": "拼团活动创建成功",
  "data": {
    "id": 1001,
    "productId": 10001,
    "originalPrice": 99.00,
    "groupPrice": 59.90,
    "targetCount": 3,
    "stock": 10,
    "durationHours": 24,
    "status": 0,
    "createdAt": "2025-07-17T10:00:00"
  },
  "timestamp": "2025-07-17T10:00:00"
}
```

*失败响应：*

```json
{
  "code": 400,
  "message": "该商品已有进行中的拼团活动",
  "data": null,
  "timestamp": "2025-07-17T10:00:00"
}
```

---

#### 3.1.2 查询拼团活动列表

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `GET /api/v1/group-buy/activities` |
| 接口描述 | 获取拼团活动列表，支持分页和筛选 |
| 是否需要认证 | 否 |
| 权限要求 | 无 |

*Query 参数：*

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| page | Integer | 否 | 1 | 页码 |
| size | Integer | 否 | 20 | 每页条数 |
| status | Integer | 否 | 0 | 活动状态筛选 |
| sort | String | 否 | created_at:desc | 排序字段 |

**响应示例：**

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 50,
    "page": 1,
    "size": 20,
    "list": [
      {
        "id": 1001,
        "productId": 10001,
        "productName": "二手iPad Air 5",
        "productImage": "https://...",
        "originalPrice": 99.00,
        "groupPrice": 59.90,
        "targetCount": 3,
        "stock": 10,
        "soldCount": 3,
        "activeTeamCount": 2,
        "status": 0,
        "createdAt": "2025-07-17T10:00:00"
      }
    ]
  },
  "timestamp": "2025-07-17T10:00:00"
}
```

---

#### 3.1.3 查询拼团活动详情

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `GET /api/v1/group-buy/activities/{activityId}` |
| 接口描述 | 获取拼团活动详情，包含商品信息和当前进行中的拼团列表 |
| 是否需要认证 | 否 |
| 权限要求 | 无 |

*Path 参数：*

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| activityId | Long | 是 | 拼团活动ID |

**响应示例：**

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1001,
    "productId": 10001,
    "productName": "二手iPad Air 5",
    "productImage": "https://...",
    "productDescription": "95新，轻微使用痕迹...",
    "originalPrice": 99.00,
    "groupPrice": 59.90,
    "discount": "6.0折",
    "targetCount": 3,
    "stock": 10,
    "remainStock": 7,
    "durationHours": 24,
    "status": 0,
    "activeTeams": [
      {
        "teamId": 2001,
        "leaderNickname": "小明",
        "leaderAvatar": "https://...",
        "currentCount": 2,
        "targetCount": 3,
        "expireAt": "2025-07-18T10:00:00",
        "remainSeconds": 43200
      }
    ],
    "createdAt": "2025-07-17T10:00:00"
  },
  "timestamp": "2025-07-17T10:00:00"
}
```

---

#### 3.1.4 取消拼团活动

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `PUT /api/v1/group-buy/activities/{activityId}/cancel` |
| 接口描述 | 卖家取消拼团活动，进行中的拼团将被取消并退款 |
| 是否需要认证 | 是 |
| 权限要求 | 商品卖家本人 |

*Path 参数：*

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| activityId | Long | 是 | 拼团活动ID |

**响应示例：**

```json
{
  "code": 200,
  "message": "拼团活动已取消，进行中的拼团将自动退款",
  "data": null,
  "timestamp": "2025-07-17T10:00:00"
}
```

---

### 3.2 拼团单管理

#### 3.2.1 发起拼团

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `POST /api/v1/group-buy/teams` |
| 接口描述 | 买家发起一个新的拼团，自动成为团长并创建拼团订单 |
| 是否需要认证 | 是 |
| 权限要求 | 已登录用户 |

**Body 参数：**

```json
{
  "activityId": 1001
}
```

| 参数名 | 类型 | 必填 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| activityId | Long | 是 | 活动必须进行中且有库存 | 拼团活动ID |

**响应示例：**

*成功响应：*

```json
{
  "code": 200,
  "message": "拼团发起成功，请完成支付",
  "data": {
    "teamId": 2001,
    "orderId": 3001,
    "groupPrice": 59.90,
    "expireAt": "2025-07-18T10:00:00",
    "paymentUrl": "https://pay.example.com/order/3001"
  },
  "timestamp": "2025-07-17T10:00:00"
}
```

---

#### 3.2.2 参与拼团

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `POST /api/v1/group-buy/teams/{teamId}/join` |
| 接口描述 | 买家参与一个已有的拼团 |
| 是否需要认证 | 是 |
| 权限要求 | 已登录用户 |

*Path 参数：*

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| teamId | Long | 是 | 拼团单ID |

**响应示例：**

*成功响应：*

```json
{
  "code": 200,
  "message": "参团成功，请完成支付",
  "data": {
    "teamId": 2001,
    "orderId": 3002,
    "groupPrice": 59.90,
    "currentCount": 2,
    "targetCount": 3,
    "paymentUrl": "https://pay.example.com/order/3002"
  },
  "timestamp": "2025-07-17T10:00:00"
}
```

*失败响应：*

```json
{
  "code": 400,
  "message": "您已参与此拼团，请勿重复参与",
  "data": null,
  "timestamp": "2025-07-17T10:00:00"
}
```

---

#### 3.2.3 查询拼团单详情

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `GET /api/v1/group-buy/teams/{teamId}` |
| 接口描述 | 获取拼团单详情，包含参团成员列表和倒计时 |
| 是否需要认证 | 否 |
| 权限要求 | 无 |

*Path 参数：*

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| teamId | Long | 是 | 拼团单ID |

**响应示例：**

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "teamId": 2001,
    "activityId": 1001,
    "productName": "二手iPad Air 5",
    "productImage": "https://...",
    "originalPrice": 99.00,
    "groupPrice": 59.90,
    "targetCount": 3,
    "currentCount": 2,
    "status": 0,
    "expireAt": "2025-07-18T10:00:00",
    "remainSeconds": 43200,
    "members": [
      {
        "userId": 101,
        "nickname": "小明",
        "avatar": "https://...",
        "isLeader": true,
        "joinedAt": "2025-07-17T10:00:00"
      },
      {
        "userId": 102,
        "nickname": "小红",
        "avatar": "https://...",
        "isLeader": false,
        "joinedAt": "2025-07-17T11:30:00"
      }
    ],
    "shareUrl": "https://example.com/group-buy/teams/2001"
  },
  "timestamp": "2025-07-17T12:00:00"
}
```

---

#### 3.2.4 查询活动下拼团列表

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `GET /api/v1/group-buy/activities/{activityId}/teams` |
| 接口描述 | 获取某拼团活动下所有进行中的拼团列表 |
| 是否需要认证 | 否 |
| 权限要求 | 无 |

*Path 参数：*

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| activityId | Long | 是 | 拼团活动ID |

**响应示例：**

```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "teamId": 2001,
      "leaderNickname": "小明",
      "leaderAvatar": "https://...",
      "currentCount": 2,
      "targetCount": 3,
      "remainSeconds": 43200,
      "expireAt": "2025-07-18T10:00:00"
    }
  ],
  "timestamp": "2025-07-17T12:00:00"
}
```

---

### 3.3 用户拼团

#### 3.3.1 我的拼团列表

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `GET /api/v1/group-buy/my-teams` |
| 接口描述 | 查询当前用户参与的所有拼团记录 |
| 是否需要认证 | 是 |
| 权限要求 | 已登录用户 |

*Query 参数：*

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| page | Integer | 否 | 1 | 页码 |
| size | Integer | 否 | 20 | 每页条数 |
| status | Integer | 否 | - | 筛选拼团状态：0-拼团中 1-已成团 2-拼团失败 |

**响应示例：**

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 5,
    "page": 1,
    "size": 20,
    "list": [
      {
        "teamId": 2001,
        "activityId": 1001,
        "productName": "二手iPad Air 5",
        "productImage": "https://...",
        "groupPrice": 59.90,
        "currentCount": 2,
        "targetCount": 3,
        "status": 0,
        "statusText": "拼团中",
        "isLeader": true,
        "expireAt": "2025-07-18T10:00:00",
        "remainSeconds": 43200,
        "orderId": 3001,
        "joinedAt": "2025-07-17T10:00:00"
      }
    ]
  },
  "timestamp": "2025-07-17T12:00:00"
}
```

---

## 4. 拼团相关错误码

| 错误码 | HTTP 状态码 | 描述 | 处理建议 |
|--------|------------|------|----------|
| 40010 | 400 | 商品已有进行中的拼团活动 | 等待当前活动结束 |
| 40011 | 400 | 拼团价格必须低于原价 | 修改拼团价格 |
| 40012 | 400 | 拼团人数不在有效范围 | 人数设为2-10 |
| 40013 | 400 | 拼团有效期不在有效范围 | 有效期设为1-72小时 |
| 40014 | 400 | 拼团库存不足 | 增加库存或减少目标人数 |
| 40020 | 400 | 该拼团已满或已结束 | 发起新拼团 |
| 40021 | 400 | 您已参与此拼团 | 不可重复参与 |
| 40022 | 400 | 拼团活动已结束 | 浏览其他活动 |
| 40023 | 400 | 商品状态异常 | 联系卖家 |

---

## 文档变更记录

| 版本 | 日期 | 变更内容 | 变更原因 |
|------|------|----------|----------|
| V1.0 | - | 初始版本 | 接口初始设计 |
| V1.1 | 2025-07-17 | 新增拼团购买相关 9 个接口 | 拼团购买功能需求 |
