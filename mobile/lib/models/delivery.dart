class Delivery {
  final int? id;
  final int orderId;
  final String? carrierName;
  final String? trackingNumber;
  final String deliveryStatus;

  Delivery({
    this.id,
    required this.orderId,
    this.carrierName,
    this.trackingNumber,
    required this.deliveryStatus,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) => Delivery(
        id: json['id'] is int
            ? json['id']
            : (json['id'] != null ? int.parse('${json['id']}') : null),
        orderId: json['order_id'] ?? json['orderId'],
        carrierName: json['carrier_name'] ?? json['carrierName'],
        trackingNumber: json['tracking_number'] ?? json['trackingNumber'],
        deliveryStatus: json['delivery_status'] ?? 'SCHEDULED',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'carrier_name': carrierName,
        'tracking_number': trackingNumber,
        'delivery_status': deliveryStatus,
      };
}
