package com.campus.trade.service;

import com.campus.trade.dto.OrderRequest;
import com.campus.trade.entity.Order;
import com.campus.trade.repository.OrderRepository;
import org.springframework.stereotype.Service;

@Service
public class OrderService {

    private final OrderRepository orderRepository;

    public OrderService(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    /**
     * 提交订单
     * BUG: 未对 deliveryAddress 做空值校验，当用户未填写地址时
     * request.getDeliveryAddress() 返回 null，调用 .trim() 抛出 NullPointerException
     */
    public Order submitOrder(OrderRequest request) {
        Order order = new Order();
        order.setBuyerId(request.getBuyerId());
        order.setProductId(request.getProductId());
        order.setQuantity(request.getQuantity());

        // ❌ BUG: request.getDeliveryAddress() 可能返回 null
        // 直接调用 .trim() 导致 NullPointerException
        String address = request.getDeliveryAddress().trim();
        order.setDeliveryAddress(address);

        order.setStatus("PENDING");
        return orderRepository.save(order);
    }
}
