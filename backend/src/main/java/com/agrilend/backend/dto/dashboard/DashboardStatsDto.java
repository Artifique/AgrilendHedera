package com.agrilend.backend.dto.dashboard;

import java.math.BigDecimal;

public class DashboardStatsDto {

    // User Stats
    private long totalUsers;
    private long totalActiveUsers;
    private long totalInactiveUsers;
    private long totalPendingUsers;
    private long totalActiveFarmers;
    private long totalActiveBuyers;

    // Offer Stats
    private long totalOffers;
    private long totalPendingOffers;
    private long totalApprovedOffers;
    private long totalRejectedOffers;

    // Order Stats
    private long totalOrders;
    private long totalPendingOrders;
    private long totalDeliveredOrders;

    // Transaction Stats
    private long totalTransactions;
    private long totalPendingTransactions;
    private long totalCompletedTransactions;
    private long totalEscrowedTransactions;

    // Delivery Stats
    private long totalDeliveries;
    private long totalScheduledDeliveries;
    private long totalDeliveredDeliveries;

    // Revenue Stats
    private BigDecimal totalRevenueLast30Days;

    // Getters and Setters

    public long getTotalUsers() {
        return totalUsers;
    }

    public void setTotalUsers(long totalUsers) {
        this.totalUsers = totalUsers;
    }

    public long getTotalActiveUsers() {
        return totalActiveUsers;
    }

    public void setTotalActiveUsers(long totalActiveUsers) {
        this.totalActiveUsers = totalActiveUsers;
    }

    public long getTotalInactiveUsers() {
        return totalInactiveUsers;
    }

    public void setTotalInactiveUsers(long totalInactiveUsers) {
        this.totalInactiveUsers = totalInactiveUsers;
    }

    public long getTotalPendingUsers() {
        return totalPendingUsers;
    }

    public void setTotalPendingUsers(long totalPendingUsers) {
        this.totalPendingUsers = totalPendingUsers;
    }

    public long getTotalActiveFarmers() {
        return totalActiveFarmers;
    }

    public void setTotalActiveFarmers(long totalActiveFarmers) {
        this.totalActiveFarmers = totalActiveFarmers;
    }

    public long getTotalActiveBuyers() {
        return totalActiveBuyers;
    }

    public void setTotalActiveBuyers(long totalActiveBuyers) {
        this.totalActiveBuyers = totalActiveBuyers;
    }

    public long getTotalOffers() {
        return totalOffers;
    }

    public void setTotalOffers(long totalOffers) {
        this.totalOffers = totalOffers;
    }

    public long getTotalPendingOffers() {
        return totalPendingOffers;
    }

    public void setTotalPendingOffers(long totalPendingOffers) {
        this.totalPendingOffers = totalPendingOffers;
    }

    public long getTotalApprovedOffers() {
        return totalApprovedOffers;
    }

    public void setTotalApprovedOffers(long totalApprovedOffers) {
        this.totalApprovedOffers = totalApprovedOffers;
    }

    public long getTotalRejectedOffers() {
        return totalRejectedOffers;
    }

    public void setTotalRejectedOffers(long totalRejectedOffers) {
        this.totalRejectedOffers = totalRejectedOffers;
    }

    public long getTotalOrders() {
        return totalOrders;
    }

    public void setTotalOrders(long totalOrders) {
        this.totalOrders = totalOrders;
    }

    public long getTotalPendingOrders() {
        return totalPendingOrders;
    }

    public void setTotalPendingOrders(long totalPendingOrders) {
        this.totalPendingOrders = totalPendingOrders;
    }

    public long getTotalDeliveredOrders() {
        return totalDeliveredOrders;
    }

    public void setTotalDeliveredOrders(long totalDeliveredOrders) {
        this.totalDeliveredOrders = totalDeliveredOrders;
    }

    public long getTotalTransactions() {
        return totalTransactions;
    }

    public void setTotalTransactions(long totalTransactions) {
        this.totalTransactions = totalTransactions;
    }

    public long getTotalPendingTransactions() {
        return totalPendingTransactions;
    }

    public void setTotalPendingTransactions(long totalPendingTransactions) {
        this.totalPendingTransactions = totalPendingTransactions;
    }

    public long getTotalCompletedTransactions() {
        return totalCompletedTransactions;
    }

    public void setTotalCompletedTransactions(long totalCompletedTransactions) {
        this.totalCompletedTransactions = totalCompletedTransactions;
    }

    public long getTotalEscrowedTransactions() {
        return totalEscrowedTransactions;
    }

    public void setTotalEscrowedTransactions(long totalEscrowedTransactions) {
        this.totalEscrowedTransactions = totalEscrowedTransactions;
    }

    public long getTotalDeliveries() {
        return totalDeliveries;
    }

    public void setTotalDeliveries(long totalDeliveries) {
        this.totalDeliveries = totalDeliveries;
    }

    public long getTotalScheduledDeliveries() {
        return totalScheduledDeliveries;
    }

    public void setTotalScheduledDeliveries(long totalScheduledDeliveries) {
        this.totalScheduledDeliveries = totalScheduledDeliveries;
    }

    public long getTotalDeliveredDeliveries() {
        return totalDeliveredDeliveries;
    }

    public void setTotalDeliveredDeliveries(long totalDeliveredDeliveries) {
        this.totalDeliveredDeliveries = totalDeliveredDeliveries;
    }

    public BigDecimal getTotalRevenueLast30Days() {
        return totalRevenueLast30Days;
    }

    public void setTotalRevenueLast30Days(BigDecimal totalRevenueLast30Days) {
        this.totalRevenueLast30Days = totalRevenueLast30Days;
    }
}
