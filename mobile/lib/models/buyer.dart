import 'package:agrilend/models/user.dart';

class Buyer extends User {
  final bool? hasHederaAccount;
  final double? hbarBalance;
  final List<String>? preferredCategories;

  Buyer({
    required super.email,
    required super.role,
    super.id,
    super.firstName,
    super.lastName,
    super.phone,
    super.address,
    super.hederaAccountId,
    super.isActive,
    super.emailVerified,
    super.createdAt,
    super.updatedAt,
    super.companyName,
    super.businessType,
    super.businessAddress,
    super.businessPhone,
    super.deliveryAddress,
    super.farmName,
    super.farmLocation,
    super.farmSize,
    this.hasHederaAccount,
    this.hbarBalance,
    this.preferredCategories,
  });

  factory Buyer.fromJson(Map<String, dynamic> json) {
    final user = User.fromJson(json); // Parse User fields
    return Buyer(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      address: user.address,
      hederaAccountId: user.hederaAccountId,
      role: user.role,
      isActive: user.isActive,
      emailVerified: user.emailVerified,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      companyName: user.companyName,
      businessType: user.businessType,
      businessAddress: user.businessAddress,
      businessPhone: user.businessPhone,
      deliveryAddress: user.deliveryAddress,
      farmName: user.farmName,
      farmLocation: user.farmLocation,
      farmSize: user.farmSize,
      hasHederaAccount: json['hederaAccountId'] != null,
      hbarBalance: json['hbarBalance'] != null
          ? double.tryParse('${json['hbarBalance']}')
          : null,
      preferredCategories: (json['preferredCategories'] is List)
          ? List<String>.from(json['preferredCategories'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(), // Include User fields
        'has_hedera_account': hasHederaAccount,
        'hbar_balance': hbarBalance,
        'preferred_categories': preferredCategories,
      };

  // Backwards-compatible getters used by feature UI
  String get businessName => companyName ?? '';

  /// Preferred categories placeholder (feature expects a list)
  List<String> get preferredCategoriesSafe => preferredCategories ?? [];

  /// Hedera helpers (placeholders until real integration)
  String get formattedHbarBalance => '${hbarBalance?.toStringAsFixed(2) ?? '0.00'} HBAR';
  bool get hasHederaAccountSafe => hasHederaAccount ?? false;
}
