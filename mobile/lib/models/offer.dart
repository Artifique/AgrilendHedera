class Offer {
  final int id;
  final int productId;
  final double availableQuantity;
  final DateTime availabilityDate;
  final double suggestedUnitPrice;
  final double finalUnitPrice;
  final String status;
  final String? notes;
  final String productName;
  final String productDescription;
  final String productUnit;
  final String? productionMethod;
  final int farmerId;
  final String farmerName;
  final String farmerEmail;
  final DateTime createdAt;
  final DateTime updatedAt;

  Offer({
    required this.id,
    required this.productId,
    required this.availableQuantity,
    required this.availabilityDate,
    required this.suggestedUnitPrice,
    required this.finalUnitPrice,
    required this.status,
    this.notes,
    required this.productName,
    required this.productDescription,
    required this.productUnit,
    this.productionMethod,
    required this.farmerId,
    required this.farmerName,
    required this.farmerEmail,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      productId: json['productId'],
      availableQuantity: (json['availableQuantity'] as num).toDouble(),
      availabilityDate: DateTime.parse(json['availabilityDate']),
      suggestedUnitPrice: (json['suggestedUnitPrice'] as num).toDouble(),
      finalUnitPrice: (json['finalUnitPrice'] as num).toDouble(),
      status: json['status'],
      notes: json['notes'],
      productName: json['productName'],
      productDescription: json['productDescription'],
      productUnit: json['productUnit'],
      productionMethod: json['productionMethod'],
      farmerId: json['farmerId'],
      farmerName: json['farmerName'],
      farmerEmail: json['farmerEmail'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Offer copyWith({
    int? id,
    int? productId,
    double? availableQuantity,
    DateTime? availabilityDate,
    double? suggestedUnitPrice,
    double? finalUnitPrice,
    String? status,
    String? notes,
    String? productName,
    String? productDescription,
    String? productUnit,
    String? productionMethod,
    int? farmerId,
    String? farmerName,
    String? farmerEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Offer(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      availabilityDate: availabilityDate ?? this.availabilityDate,
      suggestedUnitPrice: suggestedUnitPrice ?? this.suggestedUnitPrice,
      finalUnitPrice: finalUnitPrice ?? this.finalUnitPrice,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      productUnit: productUnit ?? this.productUnit,
      productionMethod: productionMethod ?? this.productionMethod,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      farmerEmail: farmerEmail ?? this.farmerEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}