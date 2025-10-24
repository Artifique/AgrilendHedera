package com.agrilend.backend.service;

import com.agrilend.backend.dto.dashboard.DashboardStatsDto;
import com.agrilend.backend.entity.Transaction;
import com.agrilend.backend.entity.enums.DeliveryStatus;
import com.agrilend.backend.entity.enums.OfferStatus;
import com.agrilend.backend.entity.enums.OrderStatus;
import com.agrilend.backend.entity.enums.TransactionType;
import com.agrilend.backend.entity.enums.UserRole;
import com.agrilend.backend.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@Transactional(readOnly = true)
public class AdminDashboardService {

    @Autowired
    private UserRepository userRepository;
    @Autowired
    private FarmerRepository farmerRepository;
    @Autowired
    private BuyerRepository buyerRepository;
    @Autowired
    private OfferRepository offerRepository;
    @Autowired
    private OrderRepository orderRepository;
    @Autowired
    private TransactionRepository transactionRepository;
    @Autowired
    private DeliveryRepository deliveryRepository;
    @Autowired
    private ProductRepository productRepository;

    public DashboardStatsDto getDashboardStats() {
        DashboardStatsDto stats = new DashboardStatsDto();

        // User Stats
        stats.setTotalUsers(userRepository.count());
        stats.setTotalActiveUsers(userRepository.countByIsActiveTrue());
        stats.setTotalInactiveUsers(userRepository.countByIsActiveFalse());
        stats.setTotalPendingUsers(userRepository.countByEmailVerifiedFalse());
        stats.setTotalActiveFarmers(farmerRepository.countByUser_IsActiveTrue());
        stats.setTotalActiveBuyers(buyerRepository.countByUser_IsActiveTrue());

        // Offer Stats
        stats.setTotalOffers(offerRepository.count());
        stats.setTotalPendingOffers(offerRepository.countByStatus(OfferStatus.PENDING_VALIDATION));
        stats.setTotalApprovedOffers(offerRepository.countByStatus(OfferStatus.ACTIVE));
        stats.setTotalRejectedOffers(offerRepository.countByStatus(OfferStatus.REJECTED));

        // Order Stats
        stats.setTotalOrders(orderRepository.count());
        stats.setTotalPendingOrders(orderRepository.countByStatus(OrderStatus.PENDING));
        stats.setTotalDeliveredOrders(orderRepository.countByStatus(OrderStatus.DELIVERED));

        // Transaction Stats
        stats.setTotalTransactions(transactionRepository.count());
        stats.setTotalPendingTransactions(transactionRepository.countByStatus(Transaction.TransactionStatus.PENDING));
        stats.setTotalCompletedTransactions(transactionRepository.countByStatus(Transaction.TransactionStatus.SUCCESS));
       // stats.setTotalEscrowedTransactions(transactionRepository.countByStatus(Transaction.TransactionStatus.IN_ESCROW));

        // Delivery Stats
        stats.setTotalDeliveries(deliveryRepository.count());
        stats.setTotalScheduledDeliveries(deliveryRepository.countByDeliveryStatus(DeliveryStatus.SCHEDULED));
        stats.setTotalDeliveredDeliveries(deliveryRepository.countByDeliveryStatus(DeliveryStatus.DELIVERED));

        // Revenue Stats (Last 30 days example)
        LocalDateTime thirtyDaysAgo = LocalDateTime.now().minusDays(30);
        stats.setTotalRevenueLast30Days(orderRepository.sumTotalAmountByCreatedAtAfter(thirtyDaysAgo));

        return stats;
    }

    public Map<LocalDate, BigDecimal> getDailyRevenue(LocalDate date) {
        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.atTime(LocalTime.MAX);
        BigDecimal revenue = orderRepository.sumTotalAmountByCreatedAtBetween(startOfDay, endOfDay);
        Map<LocalDate, BigDecimal> result = new HashMap<>();
        result.put(date, revenue != null ? revenue : BigDecimal.ZERO);
        return result;
    }

    public Map<String, BigDecimal> getMonthlyRevenue(int year, int month) {
        LocalDateTime startOfMonth = LocalDateTime.of(year, month, 1, 0, 0);
        LocalDateTime endOfMonth = startOfMonth.plusMonths(1).minusNanos(1);
        BigDecimal revenue = orderRepository.sumTotalAmountByCreatedAtBetween(startOfMonth, endOfMonth);
        Map<String, BigDecimal> result = new HashMap<>();
        result.put(String.format("%d-%02d", year, month), revenue != null ? revenue : BigDecimal.ZERO);
        return result;
    }

    public Map<String, BigDecimal> getYearlyRevenue(int year) {
        LocalDateTime startOfYear = LocalDateTime.of(year, 1, 1, 0, 0);
        LocalDateTime endOfYear = startOfYear.plusYears(1).minusNanos(1);
        BigDecimal revenue = orderRepository.sumTotalAmountByCreatedAtBetween(startOfYear, endOfYear);
        Map<String, BigDecimal> result = new HashMap<>();
        result.put(String.valueOf(year), revenue != null ? revenue : BigDecimal.ZERO);
        return result;
    }

    public Map<String, BigDecimal> getRevenueByCategory() {
        List<Object[]> results = orderRepository.sumTotalAmountByCategory();
        Map<String, BigDecimal> revenueByCategory = new HashMap<>();
        for (Object[] result : results) {
            String category = (String) result[0];
            BigDecimal revenue = (BigDecimal) result[1];
            revenueByCategory.put(category, revenue);
        }
        return revenueByCategory;
    }

    public Map<LocalDate, BigDecimal> getRevenueLast7Days() {
        Map<LocalDate, BigDecimal> result = new HashMap<>();
        LocalDate today = LocalDate.now();
        for (int i = 6; i >= 0; i--) {
            LocalDate date = today.minusDays(i);
            LocalDateTime startOfDay = date.atStartOfDay();
            LocalDateTime endOfDay = date.atTime(LocalTime.MAX);
            BigDecimal revenue = orderRepository.sumTotalAmountByCreatedAtBetween(startOfDay, endOfDay);
            result.put(date, revenue != null ? revenue : BigDecimal.ZERO);
        }
        return result;
    }

    public Map<LocalDate, BigDecimal> getRevenueLast30Days() {
        Map<LocalDate, BigDecimal> result = new HashMap<>();
        LocalDate today = LocalDate.now();
        for (int i = 29; i >= 0; i--) {
            LocalDate date = today.minusDays(i);
            LocalDateTime startOfDay = date.atStartOfDay();
            LocalDateTime endOfDay = date.atTime(LocalTime.MAX);
            BigDecimal revenue = orderRepository.sumTotalAmountByCreatedAtBetween(startOfDay, endOfDay);
            result.put(date, revenue != null ? revenue : BigDecimal.ZERO);
        }
        return result;
    }

    public Map<String, BigDecimal> getRevenueLast3Months() {
        Map<String, BigDecimal> result = new HashMap<>();
        LocalDate today = LocalDate.now();
        for (int i = 2; i >= 0; i--) {
            LocalDate monthStart = today.minusMonths(i).withDayOfMonth(1);
            LocalDateTime startOfMonth = monthStart.atStartOfDay();
            LocalDateTime endOfMonth = monthStart.plusMonths(1).atStartOfDay().minusNanos(1);
            BigDecimal revenue = orderRepository.sumTotalAmountByCreatedAtBetween(startOfMonth, endOfMonth);
            result.put(monthStart.format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM")), revenue != null ? revenue : BigDecimal.ZERO);
        }
        return result;
    }

    public Map<String, BigDecimal> getRevenueLastYear() {
        Map<String, BigDecimal> result = new HashMap<>();
        LocalDate today = LocalDate.now();
        for (int i = 11; i >= 0; i--) {
            LocalDate monthStart = today.minusMonths(i).withDayOfMonth(1);
            LocalDateTime startOfMonth = monthStart.atStartOfDay();
            LocalDateTime endOfMonth = monthStart.plusMonths(1).atStartOfDay().minusNanos(1);
            BigDecimal revenue = orderRepository.sumTotalAmountByCreatedAtBetween(startOfMonth, endOfMonth);
            result.put(monthStart.format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM")), revenue != null ? revenue : BigDecimal.ZERO);
        }
        return result;
    }
}
