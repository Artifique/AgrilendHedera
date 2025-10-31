import 'package:intl/intl.dart';

class Order {
  final int id;
  final String orderNumber;
  final int offerId;
  final double orderedQuantity;
  final double unitPrice;
  final double totalAmount;
  final String status;
  final String deliveryAddress;
  final String? notes;
  final String productName;
  final String productUnit;
  final int farmerId;
  final String farmerName;
  final int buyerId;
  final String buyerName;
  final String buyerEmail;
  final String? escrowTransactionId;
  final DateTime? escrowStartDate;
  final DateTime? escrowEndDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.offerId,
    required this.orderedQuantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    this.notes,
    required this.productName,
    required this.productUnit,
    required this.farmerId,
    required this.farmerName,
    required this.buyerId,
    required this.buyerName,
    required this.buyerEmail,
    this.escrowTransactionId,
    this.escrowStartDate,
    this.escrowEndDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['orderNumber'],
      offerId: json['offerId'],
      orderedQuantity: (json['orderedQuantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'],
      deliveryAddress: json['deliveryAddress'],
      notes: json['notes'],
      productName: json['productName'],
      productUnit: json['productUnit'],
      farmerId: json['farmerId'],
      farmerName: json['farmerName'],
      buyerId: json['buyerId'],
      buyerName: json['buyerName'],
      buyerEmail: json['buyerEmail'],
      escrowTransactionId: json['escrowTransactionId'],
      escrowStartDate: json['escrowStartDate'] != null
          ? DateTime.parse(json['escrowStartDate'])
          : null,
      escrowEndDate: json['escrowEndDate'] != null
          ? DateTime.parse(json['escrowEndDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Order copyWith({
    int? id,
    String? orderNumber,
    int? offerId,
    double? orderedQuantity,
    double? unitPrice,
    double? totalAmount,
    String? status,
    String? deliveryAddress,
    String? notes,
    String? productName,
    String? productUnit,
    int? farmerId,
    String? farmerName,
    int? buyerId,
    String? buyerName,
    String? buyerEmail,
    String? escrowTransactionId,
    DateTime? escrowStartDate,
    DateTime? escrowEndDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      offerId: offerId ?? this.offerId,
      orderedQuantity: orderedQuantity ?? this.orderedQuantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      notes: notes ?? this.notes,
      productName: productName ?? this.productName,
      productUnit: productUnit ?? this.productUnit,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      buyerEmail: buyerEmail ?? this.buyerEmail,
      escrowTransactionId: escrowTransactionId ?? this.escrowTransactionId,
      escrowStartDate: escrowStartDate ?? this.escrowStartDate,
      escrowEndDate: escrowEndDate ?? this.escrowEndDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  String get formattedQuantity => '${orderedQuantity.toStringAsFixed(2)} $productUnit';
  String get formattedTotalPrice => NumberFormat.currency(symbol: 'CFA').format(totalAmount);
  String get formattedCreatedDate => DateFormat.yMMMd('fr_FR').format(createdAt);
  DateTime? get escrowDate => escrowStartDate;
  DateTime? get deliveryDate => status == 'DELIVERED' ? updatedAt : null;

  Map<String, dynamic> toJson() => {
        'offerId': offerId,
        'orderedQuantity': orderedQuantity,
        'deliveryAddress': deliveryAddress,
        'notes': notes,
        // Les autres champs sont généralement générés par le backend ou ne sont pas envoyés lors de la création
      };
}