# 修复异常总结

## 异常描述

用户反馈提交订单时页面一直转圈，控制台报 500 错误。后端日志显示 `NullPointerException`，与地址字段有关。

---

## 根因分析

**根本原因：** `OrderService.submitOrder()` 方法中，直接对 `request.getDeliveryAddress()` 的返回值调用了 `.trim()`，未做空值校验。当用户未填写收货地址时，`getDeliveryAddress()` 返回 `null`，对 `null` 调用 `.trim()` 抛出 `NullPointerException`。

**影响链路：**
1. 前端提交订单请求，`deliveryAddress` 字段为 `null`
2. 后端 `OrderService.submitOrder()` → `request.getDeliveryAddress().trim()` → NPE
3. Spring Boot 全局异常处理未妥善捕获此异常，返回 HTTP 500
4. 前端未收到正常响应，页面持续转圈

---

## 修复方案

在调用 `.trim()` 之前，使用 `StringUtils.hasText(address)` 校验地址字段：
- 若为 `null` 或空白字符串，抛出 `BusinessException("收货地址不能为空")`
- 由全局异常处理器统一捕获并返回 HTTP 400 + 友好错误提示

**修改文件：** `OrderService.java`

```java
// 修复前（buggy）
String address = request.getDeliveryAddress().trim();

// 修复后（fixed）
String address = request.getDeliveryAddress();
if (!StringUtils.hasText(address)) {
    throw new BusinessException("收货地址不能为空");
}
order.setDeliveryAddress(address.trim());
```

---

## 输出产物

| 文件 | 说明 |
| ---- | ---- |
| `code/OrderService_buggy.java` | 修复前的问题代码 |
| `code/OrderService_fixed.java` | 修复后的代码 |
| `dev-docs/09-BUG记录.md` | 按缺陷记录模板记录的 BUG 详情 |

---

## BUG 记录摘要

### BUG-001: 提交订单时因收货地址为空导致 NullPointerException

- **级别：** 严重（S2）
- **发现场景：** 用户在提交订单页面未填写收货地址直接点击提交，页面持续转圈，控制台报 500 错误
- **复现步骤：**
  1. 登录校园二手交易平台，进入商品详情页
  2. 点击「立即购买」进入订单提交页面
  3. 不填写收货地址，直接点击「提交订单」
- **预期结果：** 前端或后端校验拦截，提示用户"收货地址不能为空"
- **实际结果：** 后端抛出 `java.lang.NullPointerException`，Spring Boot 返回 HTTP 500，前端页面一直转圈无响应
- **修复方案：** 在 `OrderService.submitOrder()` 方法中增加 `deliveryAddress` 的空值校验，使用 `StringUtils.hasText()` 判断，为空时抛出 `BusinessException("收货地址不能为空")`，由全局异常处理器返回 400 状态码和友好提示
- **状态：** 已修复

---

## Git 提交信息

```
bug: 修复提交订单时收货地址为空导致 NullPointerException 的问题
```
