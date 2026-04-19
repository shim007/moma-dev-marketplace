package com.campus.trade.service;

import com.campus.trade.dto.OrderRequest;
import com.campus.trade.entity.Order;
import com.campus.trade.exception.BusinessException;
import com.campus.trade.repository.OrderRepository;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class OrderService {

    private final OrderRepository orderRepository;

    public OrderService(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    /**
     * 提交订单
     * 修复：增加 deliveryAddress 空值校验，null 或空白字符串时抛出业务异常
     */
    public Order submitOrder(OrderRequest request) {
        Order order = new Order();
        order.setBuyerId(request.getBuyerId());
        order.setProductId(request.getProductId());
        order.setQuantity(request.getQuantity());

        // ✅ FIX: 先校验地址字段是否为空，为空则抛出明确的业务异常
        String address = request.getDeliveryAddress();
        if (!StringUtils.hasText(address)) {
            throw new BusinessException("收货地址不能为空");
        }
        order.setDeliveryAddress(address.trim());

        order.setStatus("PENDING");
        return orderRepository.save(order);
    }
}
