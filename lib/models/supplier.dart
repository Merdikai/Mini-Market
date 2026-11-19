class Supplier {
  final String id;
  final String name;
  final String companyName;
  final String email;
  final String phone;
  final String address;
  final String taxId;
  double balance; // Outstanding accounts payable
  final bool isActive;

  Supplier({
    required this.id,
    required this.name,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.address,
    this.taxId = '',
    this.balance = 0.0,
    this.isActive = true,
  });

  Supplier copyWith({
    String? id,
    String? name,
    String? companyName,
    String? email,
    String? phone,
    String? address,
    String? taxId,
    double? balance,
    bool? isActive,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      taxId: taxId ?? this.taxId,
      balance: balance ?? this.balance,
      isActive: isActive ?? this.isActive,
    );
  }
}
