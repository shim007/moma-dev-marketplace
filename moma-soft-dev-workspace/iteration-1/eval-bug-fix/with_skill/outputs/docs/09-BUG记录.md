# BUG 记录

---

### BUG-001: 提交订单时因收货地址为空导致 NullPointerException

- **级别：** 严重
- **发现场景：** 用户在提交订单页面未填写收货地址直接点击提交，页面持续转圈，控制台报 500 错误
- **复现步骤：**
  1. 登录校园二手交易平台，进入商品详情页
  2. 点击「立即购买」进入订单提交页面
  3. 不填写收货地址，直接点击「提交订单」
- **预期结果：** 前端或后端校验拦截，提示用户"收货地址不能为空"
- **实际结果：** 后端抛出 `java.lang.NullPointerException`，Spring Boot 返回 HTTP 500，前端页面一直转圈无响应
- **修复方案：** 在 `OrderService.submitOrder()` 方法中增加 `deliveryAddress` 的空值校验，使用 `StringUtils.hasText()` 判断，为空时抛出 `BusinessException("收货地址不能为空")`，由全局异常处理器返回 400 状态码和友好提示
- **状态：** 已修复
