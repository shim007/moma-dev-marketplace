# BUG 记录

---

### BUG-001: 提交订单时因收货地址为空导致 NullPointerException

- **级别：** 严重（S2）
- **优先级：** P1（紧急）
- **所属模块：** 订单模块
- **缺陷类型：** FUN（功能缺陷）
- **发现场景：** 用户在提交订单页面未填写收货地址直接点击提交，页面持续转圈，控制台报 500 错误
- **复现步骤：**
  1. 登录校园二手交易平台，进入商品详情页
  2. 点击「立即购买」进入订单提交页面
  3. 不填写收货地址，直接点击「提交订单」
- **预期结果：** 前端或后端校验拦截，提示用户"收货地址不能为空"
- **实际结果：** 后端抛出 `java.lang.NullPointerException`，Spring Boot 返回 HTTP 500，前端页面一直转圈无响应

**根因分析：**

`OrderService.submitOrder()` 方法中，直接对 `request.getDeliveryAddress()` 的返回值调用 `.trim()`。当用户未填写收货地址时，`getDeliveryAddress()` 返回 `null`，对 `null` 调用 `.trim()` 抛出 `NullPointerException`。该异常未被全局异常处理器妥善处理，导致 Spring Boot 返回 HTTP 500。

**修复方案：**

在 `OrderService.submitOrder()` 方法中增加 `deliveryAddress` 的空值校验：
- 使用 `StringUtils.hasText()` 判断地址字段是否为 `null` 或空白字符串
- 为空时抛出 `BusinessException("收货地址不能为空")`
- 由全局异常处理器统一捕获并返回 HTTP 400 状态码和友好错误提示

**修改文件：** `OrderService.java`

```java
// 修复前
String address = request.getDeliveryAddress().trim();

// 修复后
String address = request.getDeliveryAddress();
if (!StringUtils.hasText(address)) {
    throw new BusinessException("收货地址不能为空");
}
order.setDeliveryAddress(address.trim());
```

- **状态：** 已修复
- **Git 提交信息：** `bug: 修复提交订单时收货地址为空导致 NullPointerException 的问题`
