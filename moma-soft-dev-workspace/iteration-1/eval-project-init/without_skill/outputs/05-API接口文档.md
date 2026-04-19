# API 接口文档

> **定位：** 定义系统所有对外接口契约，是前后端对接和 AI 编码实现接口的唯一依据。

---

## 1. 文档信息

| 字段 | 内容 |
|------|------|
| 项目名称 | 校园二手交易平台（CampusTrade） |
| 版本 | V1.0 |
| API 基础路径 | /api/v1 |
| 认证方式 | Bearer Token (JWT) |
| 关联文档 | [产品需求文档](./02-产品需求文档.md)、[技术架构文档](./03-技术架构文档.md)、[数据模型文档](./04-数据模型文档.md) |

---

## 2. 全局约定

### 2.1 请求规范

| 约定项 | 规范 |
|--------|------|
| 内容类型 | `application/json`（文件上传使用 `multipart/form-data`） |
| 字符编码 | `UTF-8` |
| 时间格式 | ISO 8601（`yyyy-MM-dd'T'HH:mm:ss`） |
| 分页参数 | `page`（页码，从 1 开始）、`size`（每页条数，默认 20，最大 100） |
| 排序参数 | `sort=field:asc` 或 `sort=field:desc` |

### 2.2 统一响应结构

```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": "2025-07-17T10:30:00"
}
```

分页响应：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [],
    "total": 100,
    "page": 1,
    "size": 20,
    "pages": 5
  },
  "timestamp": "2025-07-17T10:30:00"
}
```

> **⚠️ AI 约束：所有接口必须使用上述统一响应结构，不得自定义响应格式。**

### 2.3 统一错误码

| 错误码 | HTTP 状态码 | 描述 | 处理建议 |
|--------|------------|------|----------|
| 200 | 200 | 成功 | - |
| 400 | 400 | 请求参数错误 | 检查请求参数 |
| 401 | 401 | 未认证 | 重新登录 |
| 403 | 403 | 无权限 | 联系管理员或完成认证 |
| 404 | 404 | 资源不存在 | 检查请求路径或资源ID |
| 409 | 409 | 资源冲突 | 如邮箱已注册、商品已在交易中 |
| 429 | 429 | 请求过于频繁 | 稍后重试 |
| 500 | 500 | 服务器内部错误 | 联系技术支持 |
| USER_1001 | 400 | 邮箱格式不正确 | 使用 edu.cn 邮箱 |
| USER_1002 | 400 | 验证码错误或已过期 | 重新获取验证码 |
| USER_1003 | 400 | 密码格式不符合要求 | 8-20位，包含字母和数字 |
| USER_1004 | 403 | 账号已被封禁 | 联系管理员 |
| USER_1005 | 429 | 登录失败次数过多 | 30分钟后重试 |
| PRODUCT_2001 | 400 | 商品图片数量超限 | 最多 9 张 |
| PRODUCT_2002 | 403 | 商品状态不允许此操作 | 检查商品当前状态 |
| ORDER_3001 | 400 | 不能购买自己的商品 | - |
| ORDER_3002 | 409 | 商品已在交易中 | 该商品已被其他人锁定 |
| CHAT_4001 | 400 | 不能与自己聊天 | - |

### 2.4 认证说明

1. 用户登录成功后，服务端返回 JWT Access Token 和 Refresh Token
2. 后续请求在 Header 中携带 Token：`Authorization: Bearer <access_token>`
3. Access Token 过期后使用 Refresh Token 获取新 Token
4. 无需认证的接口：注册、登录、商品列表、商品详情、商品搜索

---

## 3. 接口列表总览

| 模块 | 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|------|
| 认证 | 注册 | POST | /api/v1/auth/register | 用户注册 |
| 认证 | 发送验证码 | POST | /api/v1/auth/verify-code | 发送邮箱验证码 |
| 认证 | 登录 | POST | /api/v1/auth/login | 用户登录 |
| 认证 | 登出 | POST | /api/v1/auth/logout | 用户登出 |
| 认证 | 刷新Token | POST | /api/v1/auth/refresh | 刷新 Access Token |
| 用户 | 获取当前用户 | GET | /api/v1/users/me | 获取当前登录用户信息 |
| 用户 | 更新个人信息 | PUT | /api/v1/users/me | 更新个人信息 |
| 用户 | 获取用户公开信息 | GET | /api/v1/users/{id} | 获取指定用户公开资料 |
| 用户 | 上传头像 | POST | /api/v1/users/me/avatar | 上传/更新头像 |
| 商品 | 发布商品 | POST | /api/v1/products | 发布新商品 |
| 商品 | 商品列表 | GET | /api/v1/products | 获取商品列表（支持筛选排序） |
| 商品 | 商品详情 | GET | /api/v1/products/{id} | 获取商品详情 |
| 商品 | 更新商品 | PUT | /api/v1/products/{id} | 更新商品信息 |
| 商品 | 下架商品 | PUT | /api/v1/products/{id}/off-shelf | 下架商品 |
| 商品 | 上传商品图片 | POST | /api/v1/products/{id}/images | 上传商品图片 |
| 商品 | 我的发布 | GET | /api/v1/products/my | 获取当前用户发布的商品 |
| 聊天 | 创建/获取会话 | POST | /api/v1/conversations | 创建或获取已有会话 |
| 聊天 | 会话列表 | GET | /api/v1/conversations | 获取当前用户的会话列表 |
| 聊天 | 消息记录 | GET | /api/v1/conversations/{id}/messages | 获取会话消息记录 |
| 聊天 | 标记已读 | PUT | /api/v1/conversations/{id}/read | 标记会话消息为已读 |
| 交易 | 发起交易 | POST | /api/v1/orders | 发起交易 |
| 交易 | 交易详情 | GET | /api/v1/orders/{id} | 获取交易详情 |
| 交易 | 确认交易 | PUT | /api/v1/orders/{id}/confirm | 卖家确认/买家确认 |
| 交易 | 取消交易 | PUT | /api/v1/orders/{id}/cancel | 取消交易 |
| 交易 | 我的交易 | GET | /api/v1/orders/my | 获取当前用户的交易列表 |
| 交易 | 自提点列表 | GET | /api/v1/pickup-points | 获取自提点列表 |
| 评价 | 提交评价 | POST | /api/v1/reviews | 提交评价 |
| 评价 | 用户评价列表 | GET | /api/v1/reviews/user/{id} | 获取用户收到的评价 |
| 收藏 | 收藏商品 | POST | /api/v1/favorites | 收藏商品 |
| 收藏 | 取消收藏 | DELETE | /api/v1/favorites/{productId} | 取消收藏 |
| 收藏 | 收藏列表 | GET | /api/v1/favorites | 获取收藏列表 |
| 收藏 | 检查收藏状态 | GET | /api/v1/favorites/check/{productId} | 检查是否已收藏 |
| 举报 | 提交举报 | POST | /api/v1/reports | 提交举报 |
| 举报 | 举报列表（管理） | GET | /api/v1/admin/reports | 获取举报列表 |
| 举报 | 处理举报（管理） | PUT | /api/v1/admin/reports/{id} | 处理举报 |
| 通知 | 通知列表 | GET | /api/v1/notifications | 获取通知列表 |
| 通知 | 标记已读 | PUT | /api/v1/notifications/{id}/read | 标记通知已读 |
| 通知 | 全部已读 | PUT | /api/v1/notifications/read-all | 全部标记已读 |
| 通知 | 未读数量 | GET | /api/v1/notifications/unread-count | 获取未读通知数量 |

---

## 4. 接口详细定义

> **⚠️ AI 约束：以下每个接口定义都是硬性契约。AI 实现时参数名、类型、校验规则不得偏离。**

### 4.1 认证模块

#### 4.1.1 发送验证码

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `POST /api/v1/auth/verify-code` |
| 接口描述 | 发送邮箱验证码（注册用） |
| 是否需要认证 | 否 |
| 权限要求 | 无 |

*Body 参数：*

```json
{
  "email": "student@example.edu.cn"
}
```

| 参数名 | 类型 | 必填 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| email | String | 是 | 正则匹配 `.*@.*\.edu\.cn$` | 校园邮箱 |

*成功响应：*

```json
{
  "code": 200,
  "message": "验证码已发送",
  "data": null,
  "timestamp": "2025-07-17T10:30:00"
}
```

#### 4.1.2 用户注册

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `POST /api/v1/auth/register` |
| 接口描述 | 用户注册（含验证码校验） |
| 是否需要认证 | 否 |
| 权限要求 | 无 |

*Body 参数：*

```json
{
  "email": "student@example.edu.cn",
  "password": "password123",
  "nickname": "小明同学",
  "verifyCode": "123456"
}
```

| 参数名 | 类型 | 必填 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| email | String | 是 | `.*@.*\.edu\.cn$` | 校园邮箱 |
| password | String | 是 | 8-20位，包含字母和数字 | 密码 |
| nickname | String | 是 | 2-20字符 | 昵称 |
| verifyCode | String | 是 | 6位数字 | 邮箱验证码 |

*成功响应：*

```json
{
  "code": 200,
  "message": "注册成功",
  "data": {
    "id": 1,
    "email": "student@example.edu.cn",
    "nickname": "小明同学",
    "authStatus": 1
  },
  "timestamp": "2025-07-17T10:30:00"
}
```

#### 4.1.3 用户登录

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `POST /api/v1/auth/login` |
| 接口描述 | 用户登录获取 Token |
| 是否需要认证 | 否 |
| 权限要求 | 无 |

*Body 参数：*

```json
{
  "email": "student@example.edu.cn",
  "password": "password123"
}
```

| 参数名 | 类型 | 必填 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| email | String | 是 | 邮箱格式 | 邮箱 |
| password | String | 是 | 非空 | 密码 |

*成功响应：*

```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiJ9...",
    "expiresIn": 86400,
    "user": {
      "id": 1,
      "email": "student@example.edu.cn",
      "nickname": "小明同学",
      "avatarUrl": null,
      "authStatus": 1,
      "creditScore": 5.00,
      "role": "USER"
    }
  },
  "timestamp": "2025-07-17T10:30:00"
}
```

*失败响应：*

```json
{
  "code": 401,
  "message": "邮箱或密码错误",
  "data": null,
  "timestamp": "2025-07-17T10:30:00"
}
```

### 4.2 商品模块

#### 4.2.1 发布商品

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `POST /api/v1/products` |
| 接口描述 | 发布新的闲置商品 |
| 是否需要认证 | 是 |
| 权限要求 | ROLE_USER（已认证） |

*Body 参数：*

```json
{
  "title": "高等数学第七版",
  "description": "同济大学出版社，轻微笔记标注，整体品相好",
  "price": 15.00,
  "category": "TEXTBOOK",
  "itemCondition": "LIGHTLY_USED"
}
```

| 参数名 | 类型 | 必填 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| title | String | 是 | 2-50字符 | 商品标题 |
| description | String | 是 | 10-500字符 | 商品描述 |
| price | BigDecimal | 是 | 0.01-99999 | 价格 |
| category | String | 是 | 枚举值 ProductCategory | 分类 |
| itemCondition | String | 是 | 枚举值 ItemCondition | 新旧程度 |

*成功响应：*

```json
{
  "code": 200,
  "message": "发布成功",
  "data": {
    "id": 1,
    "title": "高等数学第七版",
    "description": "同济大学出版社，轻微笔记标注，整体品相好",
    "price": 15.00,
    "category": "TEXTBOOK",
    "itemCondition": "LIGHTLY_USED",
    "status": "ON_SALE",
    "images": [],
    "createdAt": "2025-07-17T10:30:00"
  },
  "timestamp": "2025-07-17T10:30:00"
}
```

#### 4.2.2 商品列表

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `GET /api/v1/products` |
| 接口描述 | 获取商品列表（仅展示在售商品） |
| 是否需要认证 | 否 |
| 权限要求 | 无 |

*Query 参数：*

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| page | Integer | 否 | 1 | 页码 |
| size | Integer | 否 | 20 | 每页条数 |
| category | String | 否 | - | 分类筛选 |
| keyword | String | 否 | - | 搜索关键词 |
| sort | String | 否 | createdAt:desc | 排序（createdAt:desc/price:asc/price:desc） |

*成功响应：*

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [
      {
        "id": 1,
        "title": "高等数学第七版",
        "price": 15.00,
        "category": "TEXTBOOK",
        "itemCondition": "LIGHTLY_USED",
        "thumbnailUrl": "/uploads/product/2025/07/17/thumb_xxx.jpg",
        "sellerNickname": "小明同学",
        "createdAt": "2025-07-17T10:30:00"
      }
    ],
    "total": 100,
    "page": 1,
    "size": 20,
    "pages": 5
  },
  "timestamp": "2025-07-17T10:30:00"
}
```

#### 4.2.3 商品详情

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `GET /api/v1/products/{id}` |
| 接口描述 | 获取商品完整详情 |
| 是否需要认证 | 否 |
| 权限要求 | 无 |

*Path 参数：*

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 商品ID |

*成功响应：*

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "title": "高等数学第七版",
    "description": "同济大学出版社，轻微笔记标注，整体品相好",
    "price": 15.00,
    "category": "TEXTBOOK",
    "itemCondition": "LIGHTLY_USED",
    "status": "ON_SALE",
    "viewCount": 42,
    "images": [
      {
        "imageUrl": "/uploads/product/2025/07/17/xxx.jpg",
        "thumbnailUrl": "/uploads/product/2025/07/17/thumb_xxx.jpg"
      }
    ],
    "seller": {
      "id": 1,
      "nickname": "小明同学",
      "avatarUrl": "/uploads/avatar/2025/07/17/yyy.jpg",
      "creditScore": 4.80
    },
    "createdAt": "2025-07-17T10:30:00",
    "updatedAt": "2025-07-17T10:30:00"
  },
  "timestamp": "2025-07-17T10:30:00"
}
```

### 4.3 交易模块

#### 4.3.1 发起交易

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `POST /api/v1/orders` |
| 接口描述 | 买家发起交易 |
| 是否需要认证 | 是 |
| 权限要求 | ROLE_USER（已认证） |

*Body 参数：*

```json
{
  "productId": 1,
  "price": 12.00,
  "pickupPointId": 3,
  "pickupTime": "2025-07-18T14:00:00"
}
```

| 参数名 | 类型 | 必填 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| productId | Long | 是 | 正整数 | 商品ID |
| price | BigDecimal | 是 | 0.01-99999 | 成交价格（议价后） |
| pickupPointId | Long | 否 | 正整数 | 自提点ID |
| pickupTime | String | 否 | ISO 8601 格式 | 约定自提时间 |

*成功响应：*

```json
{
  "code": 200,
  "message": "交易已发起，等待卖家确认",
  "data": {
    "id": 1,
    "orderNo": "CT20250717103000001",
    "productId": 1,
    "productTitle": "高等数学第七版",
    "price": 12.00,
    "status": "PENDING",
    "pickupPoint": {
      "id": 3,
      "name": "图书馆正门",
      "location": "图书馆一楼正门入口处"
    },
    "pickupTime": "2025-07-18T14:00:00",
    "createdAt": "2025-07-17T10:30:00"
  },
  "timestamp": "2025-07-17T10:30:00"
}
```

### 4.4 聊天模块

#### 4.4.1 创建/获取会话

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `POST /api/v1/conversations` |
| 接口描述 | 创建新会话或返回已存在的会话 |
| 是否需要认证 | 是 |
| 权限要求 | ROLE_USER |

*Body 参数：*

```json
{
  "productId": 1
}
```

| 参数名 | 类型 | 必填 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| productId | Long | 是 | 正整数 | 商品ID |

*成功响应：*

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "productId": 1,
    "productTitle": "高等数学第七版",
    "productThumbnail": "/uploads/product/2025/07/17/thumb_xxx.jpg",
    "otherUser": {
      "id": 2,
      "nickname": "小明同学",
      "avatarUrl": "/uploads/avatar/xxx.jpg",
      "online": true
    },
    "createdAt": "2025-07-17T10:30:00"
  },
  "timestamp": "2025-07-17T10:30:00"
}
```

---

## 5. WebSocket 接口

### 5.1 连接地址

`ws://{host}/ws/chat`

连接时通过 query 参数传递 Token：`ws://{host}/ws/chat?token={accessToken}`

### 5.2 事件定义

| 事件名 | 方向 | 描述 | 数据格式 |
|--------|------|------|----------|
| /app/chat.send | 客户端→服务端 | 发送聊天消息 | `{ conversationId, content, messageType }` |
| /topic/conversation/{id} | 服务端→客户端 | 接收聊天消息 | `{ id, senderId, senderNickname, content, messageType, createdAt }` |
| /topic/notification/{userId} | 服务端→客户端 | 接收系统通知 | `{ id, type, title, content, createdAt }` |
| /app/chat.read | 客户端→服务端 | 标记消息已读 | `{ conversationId }` |

---

## 文档变更记录

| 版本 | 日期 | 变更内容 | 变更原因 |
|------|------|----------|----------|
| V1.0 | 2025-07-17 | 初始版本 | 接口初始设计 |
