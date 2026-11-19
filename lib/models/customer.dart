class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  int loyaltyPoints;
  double storeCredit; // Customer account balance
  double totalSpent;
  int visitCount;
  final String notes;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.address = '',
    this.loyaltyPoints = 0,
    this.storeCredit = 0.0,
    this.totalSpent = 0.0,
    this.visitCount = 0,
    this.notes = '',
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    int? loyaltyPoints,
    double? storeCredit,
    double? totalSpent,
    int? visitCount,
    String? notes,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      storeCredit: storeCredit ?? this.storeCredit,
      totalSpent: totalSpent ?? this.totalSpent,
      visitCount: visitCount ?? this.visitCount,
      notes: notes ?? this.notes,
    );
  }
}
