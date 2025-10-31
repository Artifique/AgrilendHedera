class Product {
  final int? id;
  final String name;
  final String? description;
  final String category;
  final String? subcategory;
  final String unit;
  final String? imageUrl;
  final int? farmerId; // New field

  // UI-friendly optional fields
  final String? farmerName;
  final List<String>? images;
  final double? suggestedPrice;
  final double? finalPrice;
  final double? quantity;
  final bool? isAvailable;
  final bool? isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.name,
    this.description,
    required this.category,
    this.subcategory,
    required this.unit,
    this.imageUrl,
    this.farmerId, // New field
    this.farmerName,
    this.images,
    this.suggestedPrice,
    this.finalPrice,
    this.quantity,
    this.isAvailable,
    this.isVerified,
    this.createdAt,
    this.updatedAt,
  });

  double get finalPriceOrZero => finalPrice ?? suggestedPrice ?? 0.0;

  String get formattedHarvestDate {
    if (createdAt == null) return '-';
    final d = createdAt!;
    return '${d.day}/${d.month}/${d.year}';
  }

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] is int
            ? json['id']
            : (json['id'] != null ? int.parse('${json['id']}') : null),
        name: json['name'] ?? '',
        description: json['description'],
        category: json['category'] ?? '',
        subcategory: json['subcategory'],
        unit: json['unit'] ?? 'KG',
        imageUrl: json['image_url'] ?? json['imageUrl'],
        farmerId: json['farmer_id'] is int
            ? json['farmer_id']
            : (json['farmer_id'] != null ? int.parse('${json['farmer_id']}') : null), // New field
        farmerName: json['farmer_name'] ?? json['farmerName'],
        images: (json['images'] is List)
            ? List<String>.from(json['images'])
            : (json['image_url'] != null
                ? [json['image_url'].toString()]
                : null),
        suggestedPrice: json['suggested_price'] != null
            ? double.tryParse('${json['suggested_price']}')
            : null,
        finalPrice: json['final_price'] != null
            ? double.tryParse('${json['final_price']}')
            : null,
        quantity: json['quantity'] != null
            ? double.tryParse('${json['quantity']}')
            : null,
        isAvailable: json['is_available'] ?? json['available'],
        isVerified: json['is_verified'] ?? json['verified'],
        createdAt: json['created_at'] != null
            ? DateTime.tryParse('${json['created_at']}')
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse('${json['updated_at']}')
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category,
        'subcategory': subcategory,
        'unit': unit,
        'image_url': imageUrl,
        'farmer_id': farmerId, // New field
        'farmer_name': farmerName,
        'images': images,
        'suggested_price': suggestedPrice,
        'final_price': finalPrice,
        'quantity': quantity,
        'is_available': isAvailable,
        'is_verified': isVerified,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  String get formattedPrice {
    final p = finalPrice ?? suggestedPrice;
    if (p == null) return '-';
    return '${p.toStringAsFixed(0)} FCFA';
  }

  String get formattedQuantity {
    if (quantity == null) return '-';
    return '${quantity!.toStringAsFixed(2)} $unit';
  }

  List<String> get imageList => images ?? (imageUrl != null ? [imageUrl!] : []);
  double get finalPriceValue => finalPriceOrZero;
  double get finalPriceSafe => finalPriceOrZero;
  double get quantityValue => quantity ?? 0.0;
  bool get isVerifiedSafe => isVerified ?? false;

  // Backwards-compatible aliases expected by UI
  String get farmerNameSafe => farmerName ?? '';
  List<String> get imagesSafe => imageList;
  bool get verified => isVerifiedSafe;
}
