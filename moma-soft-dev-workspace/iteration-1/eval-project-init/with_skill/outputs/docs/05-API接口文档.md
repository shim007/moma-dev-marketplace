# API 接口文档

> **定位：** 定义系统所有对外和模块间的接口契约，是前后端对接和 AI 编码实现接口的唯一依据。
> **生成时机：** 技术架构文档和数据模型文档确认后，由 AI 基于产品需求和技术架构生成。
> **使用方式：** AI 实现接口时，路径、方法、参数、响应结构必须与本文档完全一致。

---

## 1. 文档信息

| 字段 | 内容 |
|------|------|
| 项目名称 | 校园二手交易平台 |
| 版本 | V1.0 |
| API 基础路径 | /api/v1 |
| 认证方式 | Bearer Token (JWT) |
| 关联文档 | [产品需求文档](./02-产品需求文档.md)、[技术架构文档](./03-技术架构文档.md)、[数据模型文档](./04-数据模型文档.md) |

---

## 2. 全局约定

### 2.1 请求规范

| 约定项 | 规范 |
|--------|------|
| 内容类型 | `application/json` |
| 字符编码 | `UTF-8` |
| 时间格式 | ISO 8601（`yyyy-MM-dd'T'HH:mm:ss`） |
| 分页参数 | `page`（页码，从1开始）、`size`（每页条数，默认20） |
| 排序参数 | `sort=field:asc` 或 `sort=field:desc` |

### 2.2 统一响应结构

```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": "2025-07-17T12:00:00"
}
```

> **⚠️ AI 约束：所有接口必须使用上述统一响应结构，不得自定义响应格式。**

分页响应的 `data` 字段结构：

```json
{
  "content": [],
  "page": 1,
  "size": 20,
  "totalElements": 100,
  "totalPages": 5
}
```

### 2.3 统一错误码

| 错误码 | HTTP 状态码 | 描述 | 处理建议 |
|--------|------------|------|----------|
| 200 | 200 | 成功 | - |
| 400 | 400 | 请求参数错误 | 检查请求参数 |
| 401 | 401 | 未认证 | 重新登录 |
| 403 | 403 | 无权限 | 需完成学生身份认证或无操作权限 |
| 404 | 404 | 资源不存在 | 检查请求路径或资源ID |
| 409 | 409 | 资源冲突 | 如学号已注册、商品已有进行中交易等 |
| 422 | 422 | 业务规则校验失败 | 如未认证用户发布商品、卖家自买等 |
| 429 | 429 | 请求频率超限 | 稍后重试 |
| 500 | 500 | 服务器内部错误 | 联系技术支持 |

### 2.4 认证说明

- 用户登录成功后，服务端返回 JWT Token（Access Token + Refresh Token）
- 前端在后续请求中通过 `Authorization: Bearer {accessToken}` 携带 Token
- Access Token 有效期 2 小时，Refresh Token 有效期 7 天
- Token 过期后使用 Refresh Token 换取新的 Access Token
- 未携带或 Token 无效返回 401，认证不足（如未完成学生认证）返回 403

---

## 3. 接口列表总览

| 模块 | 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|------|
| 认证 | 注册 | POST | /api/v1/auth/register | 学号+密码注册 |
| 认证 | 登录 | POST | /api/v1/auth/login | 学号+密码登录 |
| 认证 | 刷新Token | POST | /api/v1/auth/refresh | 刷新 Access Token |
| 认证 | 发送验证邮件 | POST | /api/v1/auth/verify-email/send | 发送学校邮箱验证 |
| 认证 | 确认邮箱验证 | GET | /api/v1/auth/verify-email/confirm | 确认邮箱验证链接 |
| 用户 | 获取当前用户信息 | GET | /api/v1/users/me | 获取当前登录用户信息 |
| 用户 | 更新个人信息 | PUT | /api/v1/users/me | 修改昵称/简介/头像 |
| 用户 | 获取用户公开信息 | GET | /api/v1/users/{id} | 查看其他用户公开信息 |
| 用户 | 修改密码 | PUT | /api/v1/users/me/password | 修改登录密码 |
| 商品 | 发布商品 | POST | /api/v1/products | 发布闲置商品 |
| 商品 | 获取商品列表 | GET | /api/v1/products | 分页查询商品列表 |
| 商品 | 获取商品详情 | GET | /api/v1/products/{id} | 获取商品详细信息 |
| 商品 | 更新商品 | PUT | /api/v1/products/{id} | 更新商品信息 |
| 商品 | 下架/上架商品 | PATCH | /api/v1/products/{id}/status | 切换商品上下架状态 |
| 商品 | 删除商品 | DELETE | /api/v1/products/{id} | 软删除商品 |
| 商品 | 上传图片 | POST | /api/v1/upload/image | 上传商品/聊天图片 |
| 商品 | 获取我的商品 | GET | /api/v1/products/mine | 获取当前用户发布的商品 |
| 聊天 | 获取/创建会话 | POST | /api/v1/conversations | 获取或创建聊天会话 |
| 聊天 | 获取会话列表 | GET | /api/v1/conversations | 获取我的会话列表 |
| 聊天 | 获取消息历史 | GET | /api/v1/conversations/{id}/messages | 获取某会话的消息列表 |
| 聊天 | 标记已读 | PUT | /api/v1/conversations/{id}/read | 标记会话消息已读 |
| 交易 | 发起交易 | POST | /api/v1/trades | 买家发起交易请求 |
| 交易 | 获取交易详情 | GET | /api/v1/trades/{id} | 获取交易详细信息 |
| 交易 | 获取我的交易 | GET | /api/v1/trades/mine | 获取我参与的交易列表 |
| 交易 | 确认/拒绝交易 | PATCH | /api/v1/trades/{id}/respond | 卖家接受或拒绝交易 |
| 交易 | 设置自提信息 | PUT | /api/v1/trades/{id}/pickup | 设置自提地点和时间 |
| 交易 | 确认完成 | PATCH | /api/v1/trades/{id}/complete | 确认交易完成 |
| 交易 | 取消交易 | PATCH | /api/v1/trades/{id}/cancel | 取消交易 |
| 自提点 | 获取自提点列表 | GET | /api/v1/pickup-points | 获取校内自提点列表 |
| 评价 | 提交评价 | POST | /api/v1/reviews | 交易完成后提交评价 |
| 评价 | 获取用户评价 | GET | /api/v1/users/{id}/reviews | 获取某用户的评价列表 |
| 收藏 | 收藏商品 | POST | /api/v1/favorites | 收藏商品 |
| 收藏 | 取消收藏 | DELETE | /api/v1/favorites/{productId} | 取消收藏 |
| 收藏 | 获取收藏列表 | GET | /api/v1/favorites | 获取我的收藏列表 |
| 通知 | 获取通知列表 | GET | /api/v1/notifications | 获取我的通知列表 |
| 通知 | 标记已读 | PUT | /api/v1/notifications/{id}/read | 标记单条通知已读 |
| 通知 | 全部标记已读 | PUT | /api/v1/notifications/read-all | 全部标记已读 |
| 通知 | 获取未读数量 | GET | /api/v1/notifications/unread-count | 获取未读通知数量 |

---

## 4. 接口详细定义

> **⚠️ AI 约束：以下每个接口定义都是硬性契约。AI 实现时参数名、类型、校验规则不得偏离。**

### 4.1 认证模块

#### 4.1.1 用户注册

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `POST /api/v1/auth/register` |
| 接口描述 | 使用学号和密码注册新账号 |
| 是否需要认证 | 否 |
| 权限要求 | 无 |

**Body 参数：**

```json
{
  "studentId": "2021001001",
  "password": "Password123!",
  "nickname": "小明同学"
}
```

| 参数名 | 类型 | 必填 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| studentId | String | 是 | 长度6-20，仅字母数字 | 学号 |
| password | String | 是 | 长度8-20，需包含大小写字母和数字 | 登录密码 |
| nickname | String | 是 | 长度2-30 | 昵称 |

**响应示例：**

*成功响应：*

```json
{
  "code": 200,
  "message": "注册成功",
  "data": {
    "id": 1,
    "studentId": "2021001001",
    "nickname": "小明同学",
    "authStatus": 0
  },
  "timestamp": "2025-07-17T12:00:00"
}
```

*失败响应：*

```json
{
  "code": 409,
  "message": "该学号已注册",
  "data": null,
  "timestamp": "2025-07-17T12:00:00"
}
```

#### 4.1.2 用户登录

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `POST /api/v1/auth/login` |
| 接口描述 | 使用学号和密码登录 |
| 是否需要认证 | 否 |
| 权限要求 | 无 |

**Body 参数：**

```json
{
  "studentId": "2021001001",
  "password": "Password123!"
}
```

| 参数名 | 类型 | 必填 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| studentId | String | 是 | 非空 | 学号 |
| password | String | 是 | 非空 | 密码 |

**响应示例：**

*成功响应：*

```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiJ9...",
    "expiresIn": 7200,
    "user": {
      "id": 1,
      "studentId": "2021001001",
      "nickname": "小明同学",
      "avatarUrl": null,
      "authStatus": 1,
      "creditScore": 5.0
    }
  },
  "timestamp": "2025-07-17T12:00:00"
}
```

*失败响应：*

```json
{
  "code": 401,
  "message": "学号或密码错误",
  "data": null,
  "timestamp": "2025-07-17T12:00:00"
}
```

#### 4.1.3 刷新Token

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `POST /api/v1/auth/refresh` |
| 接口描述 | 使用 Refresh Token 获取新的 Access Token |
| 是否需要认证 | 否 |
| 权限要求 | 无 |

**Body 参数：**

```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiJ9..."
}
```

| 参数名 | 类型 | 必填 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| refreshToken | String | 是 | 非空 | Refresh Token |

**响应示例：**

*成功响应：*

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiJ9...",
    "expiresIn": 7200
  },
  "timestamp": "2025-07-17T12:00:00"
}
```

#### 4.1.4 发送验证邮件

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `POST /api/v1/auth/verify-email/send` |
| 接口描述 | 向学校邮箱发送验证邮件 |
| 是否需要认证 | 是 |
| 权限要求 | 已登录用户 |

**Body 参数：**

```json
{
  "email": "student@school.edu.cn"
}
```

| 参数名 | 类型 | 必填 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| email | String | 是 | 合法邮箱格式 | 学校邮箱地址 |

**响应示例：**

*成功响应：*

```json
{
  "code": 200,
  "message": "验证邮件已发送",
  "data": null,
  "timestamp": "2025-07-17T12:00:00"
}
```

#### 4.1.5 确认邮箱验证

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `GET /api/v1/auth/verify-email/confirm` |
| 接口描述 | 用户点击邮件中的验证链接完成认证 |
| 是否需要认证 | 否 |
| 权限要求 | 无 |

*Query 参数：*

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| token | String | 是 | - | 验证令牌 |

**响应示例：**

*成功响应：*

```json
{
  "code": 200,
  "message": "邮箱验证成功，学生身份已认证",
  "data": null,
  "timestamp": "2025-07-17T12:00:00"
}
```

### 4.2 用户模块

#### 4.2.1 获取当前用户信息

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `GET /api/v1/users/me` |
| 接口描述 | 获取当前登录用户的详细信息 |
| 是否需要认证 | 是 |
| 权限要求 | 已登录用户 |

**响应示例：**

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "studentId": "2021001001",
    "nickname": "小明同学",
    "avatarUrl": "/files/avatars/1/uuid.jpg",
    "email": "student@school.edu.cn",
    "bio": "大三学生，爱好编程",
    "authStatus": 1,
    "creditScore": 4.8,
    "createdAt": "2025-07-17T12:00:00"
  },
  "timestamp": "2025-07-17T12:00:00"
}
```

#### 4.2.2 更新个人信息

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `PUT /api/v1/users/me` |
| 接口描述 | 修改个人昵称、简介、头像 |
| 是否需要认证 | 是 |
| 权限要求 | 已登录用户 |

**Body 参数：**

```json
{
  "nickname": "小明同学",
  "bio": "大三学生",
  "avatarUrl": "/files/avatars/1/uuid.jpg"
}
```

| 参数名 | 类型 | 必填 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| nickname | String | 否 | 长度2-30 | 昵称 |
| bio | String | 否 | 长度≤200 | 个人简介 |
| avatarUrl | String | 否 | 合法URL | 头像地址 |

#### 4.2.3 获取用户公开信息

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `GET /api/v1/users/{id}` |
| 接口描述 | 查看其他用户的公开信息 |
| 是否需要认证 | 否 |
| 权限要求 | 无 |

*Path 参数：*

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 用户ID |

**响应示例：**

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "nickname": "小明同学",
    "avatarUrl": "/files/avatars/1/uuid.jpg",
    "creditScore": 4.8,
    "authStatus": 1,
    "createdAt": "2025-07-17T12:00:00"
  },
  "timestamp": "2025-07-17T12:00:00"
}
```

### 4.3 商品模块

#### 4.3.1 发布商品

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `POST /api/v1/products` |
| 接口描述 | 已认证用户发布闲置商品 |
| 是否需要认证 | 是 |
| 权限要求 | 已认证用户（authStatus=1） |

**Body 参数：**

```json
{
  "title": "iPhone 14 Pro 256G 国行",
  "description": "使用一年，电池健康96%，无磕碰，配件齐全",
  "price": 5999.00,
  "category": "DIGITAL",
  "conditionLevel": 2,
  "imageUrls": [
    "/files/products/2025/07/17/uuid1.jpg",
    "/files/products/2025/07/17/uuid2.jpg"
  ]
}
```

| 参数名 | 类型 | 必填 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| title | String | 是 | 长度5-50 | 商品标题 |
| description | String | 是 | 长度10-500 | 商品描述 |
| price | BigDecimal | 是 | 0.01-99999.99 | 商品价格 |
| category | String | 是 | 枚举值校验 | 商品分类 |
| conditionLevel | Integer | 是 | 1-4 | 成色等级 |
| imageUrls | List<String> | 是 | 1-9个元素 | 图片URL列表 |

**响应示例：**

*成功响应：*

```json
{
  "code": 200,
  "message": "商品发布成功",
  "data": {
    "id": 1,
    "title": "iPhone 14 Pro 256G 国行",
    "price": 5999.00,
    "status": 1
  },
  "timestamp": "2025-07-17T12:00:00"
}
```

#### 4.3.2 获取商品列表

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `GET /api/v1/products` |
| 接口描述 | 分页查询商品列表，支持分类筛选和关键词搜索 |
| 是否需要认证 | 否 |
| 权限要求 | 无 |

*Query 参数：*

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| page | Integer | 否 | 1 | 页码 |
| size | Integer | 否 | 20 | 每页条数 |
| keyword | String | 否 | - | 搜索关键词 |
| category | String | 否 | - | 分类筛选 |
| sort | String | 否 | createdAt:desc | 排序（price:asc/price:desc/createdAt:desc） |

**响应示例：**

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "content": [
      {
        "id": 1,
        "title": "iPhone 14 Pro 256G 国行",
        "price": 5999.00,
        "category": "DIGITAL",
        "conditionLevel": 2,
        "coverImageUrl": "/files/products/2025/07/17/uuid1.jpg",
        "sellerNickname": "小明同学",
        "createdAt": "2025-07-17T12:00:00"
      }
    ],
    "page": 1,
    "size": 20,
    "totalElements": 50,
    "totalPages": 3
  },
  "timestamp": "2025-07-17T12:00:00"
}
```

#### 4.3.3 获取商品详情

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `GET /api/v1/products/{id}` |
| 接口描述 | 获取商品详细信息 |
| 是否需要认证 | 否 |
| 权限要求 | 无 |

*Path 参数：*

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 商品ID |

**响应示例：**

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "title": "iPhone 14 Pro 256G 国行",
    "description": "使用一年，电池健康96%，无磕碰，配件齐全",
    "price": 5999.00,
    "category": "DIGITAL",
    "conditionLevel": 2,
    "status": 1,
    "viewCount": 120,
    "imageUrls": [
      "/files/products/2025/07/17/uuid1.jpg",
      "/files/products/2025/07/17/uuid2.jpg"
    ],
    "seller": {
      "id": 1,
      "nickname": "小明同学",
      "avatarUrl": "/files/avatars/1/uuid.jpg",
      "creditScore": 4.8
    },
    "isFavorited": false,
    "createdAt": "2025-07-17T12:00:00",
    "updatedAt": "2025-07-17T12:00:00"
  },
  "timestamp": "2025-07-17T12:00:00"
}
```

#### 4.3.4 上传图片

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `POST /api/v1/upload/image` |
| 接口描述 | 上传图片文件（商品图片/聊天图片/头像） |
| 是否需要认证 | 是 |
| 权限要求 | 已登录用户 |

**请求参数：** `multipart/form-data`

| 参数名 | 类型 | 必填 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| file | File | 是 | ≤5MB，JPG/PNG/WEBP | 图片文件 |
| type | String | 是 | product/avatar/chat | 图片用途分类 |

**响应示例：**

```json
{
  "code": 200,
  "message": "上传成功",
  "data": {
    "url": "/files/products/2025/07/17/uuid.jpg"
  },
  "timestamp": "2025-07-17T12:00:00"
}
```

### 4.4 聊天模块

#### 4.4.1 获取或创建会话

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `POST /api/v1/conversations` |
| 接口描述 | 根据商品ID获取已有会话或创建新会话 |
| 是否需要认证 | 是 |
| 权限要求 | 已认证用户 |

**Body 参数：**

```json
{
  "productId": 1
}
```

| 参数名 | 类型 | 必填 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| productId | Long | 是 | 商品必须存在且在售 | 商品ID |

**响应示例：**

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "productId": 1,
    "productTitle": "iPhone 14 Pro 256G 国行",
    "otherUser": {
      "id": 2,
      "nickname": "卖家小红",
      "avatarUrl": "/files/avatars/2/uuid.jpg"
    },
    "lastMessageContent": null,
    "lastMessageTime": null,
    "unreadCount": 0
  },
  "timestamp": "2025-07-17T12:00:00"
}
```

#### 4.4.2 获取会话列表

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `GET /api/v1/conversations` |
| 接口描述 | 获取当前用户的所有聊天会话 |
| 是否需要认证 | 是 |
| 权限要求 | 已登录用户 |

**响应示例：**

```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "productId": 1,
      "productTitle": "iPhone 14 Pro",
      "productCoverUrl": "/files/products/2025/07/17/uuid.jpg",
      "otherUser": {
        "id": 2,
        "nickname": "卖家小红",
        "avatarUrl": "/files/avatars/2/uuid.jpg"
      },
      "lastMessageContent": "价格可以商量吗？",
      "lastMessageTime": "2025-07-17T14:30:00",
      "unreadCount": 2
    }
  ],
  "timestamp": "2025-07-17T12:00:00"
}
```

#### 4.4.3 获取消息历史

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `GET /api/v1/conversations/{id}/messages` |
| 接口描述 | 获取某会话的历史消息，分页查询 |
| 是否需要认证 | 是 |
| 权限要求 | 会话参与者 |

*Path 参数：*

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | Long | 是 | 会话ID |

*Query 参数：*

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| page | Integer | 否 | 1 | 页码 |
| size | Integer | 否 | 50 | 每页条数 |

**响应示例：**

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "content": [
      {
        "id": 1,
        "senderId": 1,
        "senderNickname": "小明同学",
        "senderAvatarUrl": "/files/avatars/1/uuid.jpg",
        "content": "你好，这个还在吗？",
        "messageType": 1,
        "createdAt": "2025-07-17T14:00:00"
      }
    ],
    "page": 1,
    "size": 50,
    "totalElements": 10,
    "totalPages": 1
  },
  "timestamp": "2025-07-17T12:00:00"
}
```

### 4.5 交易模块

#### 4.5.1 发起交易

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `POST /api/v1/trades` |
| 接口描述 | 买家对商品发起交易请求 |
| 是否需要认证 | 是 |
| 权限要求 | 已认证用户 |

**Body 参数：**

```json
{
  "productId": 1,
  "price": 5500.00
}
```

| 参数名 | 类型 | 必填 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| productId | Long | 是 | 商品存在且在售，无进行中交易 | 商品ID |
| price | BigDecimal | 是 | 正数，≤99999.99 | 期望成交价 |

#### 4.5.2 确认/拒绝交易

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `PATCH /api/v1/trades/{id}/respond` |
| 接口描述 | 卖家接受或拒绝买家的交易请求 |
| 是否需要认证 | 是 |
| 权限要求 | 交易的卖家 |

**Body 参数：**

```json
{
  "accepted": true
}
```

| 参数名 | 类型 | 必填 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| accepted | Boolean | 是 | - | true=接受，false=拒绝 |

#### 4.5.3 设置自提信息

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `PUT /api/v1/trades/{id}/pickup` |
| 接口描述 | 设置自提地点和时间 |
| 是否需要认证 | 是 |
| 权限要求 | 交易参与者 |

**Body 参数：**

```json
{
  "pickupPointId": 1,
  "pickupLocation": null,
  "pickupTime": "2025-07-18T14:00:00"
}
```

| 参数名 | 类型 | 必填 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| pickupPointId | Long | 否 | 与pickupLocation二选一 | 预设自提点ID |
| pickupLocation | String | 否 | 长度≤200 | 自定义地点描述 |
| pickupTime | String | 是 | ISO 8601，必须为未来时间 | 自提时间 |

#### 4.5.4 确认交易完成

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `PATCH /api/v1/trades/{id}/complete` |
| 接口描述 | 交易参与者确认交易完成 |
| 是否需要认证 | 是 |
| 权限要求 | 交易参与者（买卖双方均需确认） |

#### 4.5.5 取消交易

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `PATCH /api/v1/trades/{id}/cancel` |
| 接口描述 | 取消交易 |
| 是否需要认证 | 是 |
| 权限要求 | 交易参与者 |

**Body 参数：**

```json
{
  "reason": "价格未达成一致"
}
```

| 参数名 | 类型 | 必填 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| reason | String | 否 | 长度≤200 | 取消原因 |

### 4.6 评价模块

#### 4.6.1 提交评价

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `POST /api/v1/reviews` |
| 接口描述 | 交易完成后提交评价 |
| 是否需要认证 | 是 |
| 权限要求 | 交易参与者 |

**Body 参数：**

```json
{
  "tradeId": 1,
  "rating": 5,
  "content": "东西很好，卖家很热情"
}
```

| 参数名 | 类型 | 必填 | 校验规则 | 说明 |
|--------|------|------|----------|------|
| tradeId | Long | 是 | 交易存在且已完成，7天内 | 交易ID |
| rating | Integer | 是 | 1-5 | 评分 |
| content | String | 否 | 长度≤200 | 评价内容 |

### 4.7 收藏模块

#### 4.7.1 收藏商品

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `POST /api/v1/favorites` |
| 接口描述 | 收藏商品 |
| 是否需要认证 | 是 |
| 权限要求 | 已登录用户 |

**Body 参数：**

```json
{
  "productId": 1
}
```

#### 4.7.2 取消收藏

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `DELETE /api/v1/favorites/{productId}` |
| 接口描述 | 取消收藏 |
| 是否需要认证 | 是 |
| 权限要求 | 已登录用户 |

### 4.8 自提点模块

#### 4.8.1 获取自提点列表

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `GET /api/v1/pickup-points` |
| 接口描述 | 获取校内预设自提点列表 |
| 是否需要认证 | 否 |
| 权限要求 | 无 |

**响应示例：**

```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "name": "校门口",
      "description": "学校正门保安亭旁"
    },
    {
      "id": 2,
      "name": "1号食堂门口",
      "description": "1号食堂正门入口处"
    }
  ],
  "timestamp": "2025-07-17T12:00:00"
}
```

### 4.9 通知模块

#### 4.9.1 获取通知列表

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `GET /api/v1/notifications` |
| 接口描述 | 分页获取当前用户的通知列表 |
| 是否需要认证 | 是 |
| 权限要求 | 已登录用户 |

*Query 参数：*

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| page | Integer | 否 | 1 | 页码 |
| size | Integer | 否 | 20 | 每页条数 |
| type | Integer | 否 | - | 通知类型筛选 |

#### 4.9.2 获取未读数量

**基本信息：**

| 项目 | 内容 |
|------|------|
| 接口路径 | `GET /api/v1/notifications/unread-count` |
| 接口描述 | 获取未读通知数量 |
| 是否需要认证 | 是 |
| 权限要求 | 已登录用户 |

**响应示例：**

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 5,
    "trade": 2,
    "chat": 2,
    "system": 1
  },
  "timestamp": "2025-07-17T12:00:00"
}
```

---

## 5. WebSocket 接口

### 5.1 连接地址

`ws://{host}/ws/chat?token={accessToken}`

### 5.2 事件定义

| 事件名 | 方向 | 描述 | 数据格式 |
|--------|------|------|----------|
| /app/chat.send | 客户端→服务端 | 发送聊天消息 | `{ "conversationId": 1, "content": "hello", "messageType": 1 }` |
| /user/queue/messages | 服务端→客户端 | 接收新消息 | `{ "id": 1, "conversationId": 1, "senderId": 2, "content": "hi", "messageType": 1, "createdAt": "..." }` |
| /user/queue/notifications | 服务端→客户端 | 接收通知 | `{ "id": 1, "type": 1, "title": "...", "content": "..." }` |

---

## 文档变更记录

| 版本 | 日期 | 变更内容 | 变更原因 |
|------|------|----------|----------|
| V1.0 | 2025-07-17 | 初始版本 | 接口初始设计 |
