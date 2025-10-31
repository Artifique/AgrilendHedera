class User {
  final int? id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? address;
  final String? hederaAccountId;
  final String role;
  final bool? isActive;
  final bool? emailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? companyName;
  final String? businessType;
  final String? businessAddress;
  final String? businessPhone;
final String? deliveryAddress;
  final String? farmName;
  final String? farmLocation;
  final String? farmSize;


  User({
    this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.address,
    this.hederaAccountId,
    required this.role,
    this.isActive,
    this.emailVerified,
    this.createdAt,
    this.updatedAt,
    this.companyName,
    this.businessType,
    this.businessAddress,
    this.businessPhone,
    this.deliveryAddress,
    this.farmName,
    this.farmLocation,
    this.farmSize,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] is int
            ? json['id']
            : (json['id'] != null ? int.parse('${json['id']}') : null),
        email: json['email'] ?? '',
        firstName: json['first_name'] ?? json['firstName'],
        lastName: json['last_name'] ?? json['lastName'],
        phone: json['phone'],
        address: json['address'],
        hederaAccountId: json['hedera_account_id'] ?? json['hederaAccountId'],
        role: json['role'] ?? 'FARMER',
        isActive: json['is_active'] ?? json['isActive'] ?? json['active'],
        emailVerified: json['email_verified'] ?? json['emailVerified'],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : (json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null),
        companyName: json['companyName'],
        businessType: json['activityType'],
        businessAddress: json['companyAddress'],
        businessPhone: json['phone'],
        deliveryAddress: json['deliveryAddress'],
        farmName: json['farmName'],
        farmLocation: json['farmLocation'],
        farmSize: json['farmSize'],
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'address': address,
        'hedera_account_id': hederaAccountId,
        'role': role,
        'is_active': isActive,
        'email_verified': emailVerified,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'companyName': companyName,
        'activityType': businessType,
        'companyAddress': businessAddress,
        'business_phone': businessPhone,
        'delivery_address': deliveryAddress,
        'farmName': farmName,
        'farmLocation': farmLocation,
        'farmSize': farmSize,
      };

  User copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    String? hederaAccountId,
    String? role,
    bool? isActive,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? companyName,
    String? businessType,
    String? businessAddress,
    String? businessPhone,
    String? deliveryAddress,
    String? farmName,
    String? farmLocation,
    String? farmSize,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      hederaAccountId: hederaAccountId ?? this.hederaAccountId,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      companyName: companyName ?? this.companyName,
      businessType: businessType ?? this.businessType,
      businessAddress: businessAddress ?? this.businessAddress,
      businessPhone: businessPhone ?? this.businessPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      farmName: farmName ?? this.farmName,
      farmLocation: farmLocation ?? this.farmLocation,
      farmSize: farmSize ?? this.farmSize,
    );
  }
  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  /// Feature code expects `userType` string normalized to one of:
  /// 'farmer', 'buyer', 'agent'
  String get userType {
    final r = role.toLowerCase();
    if (r.contains('farm') || r == 'farmer') return 'farmer';
    if (r.contains('agent') || r.contains('admin')) return 'agent';
    if (r.contains('buy') || r == 'buyer') return 'buyer';
    // fallback: if role looks like a single-letter code
    if (r == 'f') return 'farmer';
    if (r == 'a') return 'agent';
    if (r == 'b') return 'buyer';
    return 'buyer';
  }
}
