import '../core/constants/app_constants.dart';

class StaffUser {
  final String id;
  final String name;
  final String email;
  final StaffRole role;
  final String pin; // 4-digit PIN for quick cashier terminal login
  final String phone;
  final String avatarUrl;
  final bool isActive;

  const StaffUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.pin,
    this.phone = '',
    this.avatarUrl = '',
    this.isActive = true,
  });

  StaffUser copyWith({
    String? id,
    String? name,
    String? email,
    StaffRole? role,
    String? pin,
    String? phone,
    String? avatarUrl,
    bool? isActive,
  }) {
    return StaffUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      pin: pin ?? this.pin,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}
