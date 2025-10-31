class Farmer {
  final int userId;
  final String? farmName;
  final String? farmLocation;
  final double? farmSizeHectares;
  final Map<String, dynamic>? certifications;

  Farmer({
    required this.userId,
    this.farmName,
    this.farmLocation,
    this.farmSizeHectares,
    this.certifications,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) => Farmer(
        userId: json['user_id'] ?? json['userId'],
        farmName: json['farm_name'] ?? json['farmName'],
        farmLocation: json['farm_location'] ?? json['farmLocation'],
        farmSizeHectares: json['farm_size_hectares'] != null
            ? double.tryParse('${json['farm_size_hectares']}')
            : null,
        certifications: json['certifications'] is Map
            ? Map<String, dynamic>.from(json['certifications'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'farm_name': farmName,
        'farm_location': farmLocation,
        'farm_size_hectares': farmSizeHectares,
        'certifications': certifications,
      };
}
