import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/tilt_card_3d.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'VIP PROFILE & VAULT',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 3D Holographic VIP Card
            TiltCard3D(
              maxTiltAngle: 0.18,
              child: Container(
                width: double.infinity,
                height: 210,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1B1F33),
                      Color(0xFF0F121C),
                      Color(0xFF1E1528),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.champagneGold.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.champagneGold.withValues(alpha: 0.22),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.diamond_outlined, color: AppColors.champagneGold, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'ORA LOYALTY CLUB',
                              style: TextStyle(
                                color: AppColors.champagneGold,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.champagneGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.champagneGold, width: 1),
                          ),
                          child: const Text(
                            'TIER 01 • GENEVA',
                            style: TextStyle(
                              color: AppColors.champagneGold,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MEMBER IDENTIFIER',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 9, letterSpacing: 1.2),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'MM-9042-8819',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('HOLDER', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
                            Text('ALEXANDRE MERCER',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: AppColors.champagneGold),
                            const SizedBox(width: 4),
                            Text(
                              '${store.orders.length * 1500 + 4200} PTS',
                              style: const TextStyle(
                                color: AppColors.champagneGold,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // 2. Order History Timeline
            const Text(
              'ORDER DISPATCH HISTORY',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            if (store.orders.isEmpty)
              const GlassContainer(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text('No past orders on record.', style: TextStyle(color: AppColors.textMuted)),
                ),
              )
            else
              ...store.orders.map((order) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 18,
                    backgroundColor: AppColors.surfaceElevated.withValues(alpha: 0.7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.id,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: order.status == 'Delivered'
                                    ? AppColors.cyberEmerald.withValues(alpha: 0.15)
                                    : AppColors.neonCyan.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order.status.toUpperCase(),
                                style: TextStyle(
                                  color: order.status == 'Delivered'
                                      ? AppColors.cyberEmerald
                                      : AppColors.neonCyan,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${order.items.length} artifacts • \$${order.total.toStringAsFixed(0)}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dispatched on ${order.date.toIso8601String().split('T').first}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 28),

            // 3. Vault Settings
            const Text(
              'APPLICATION SETTINGS',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              borderRadius: 18,
              backgroundColor: AppColors.surfaceElevated.withValues(alpha: 0.7),
              child: Column(
                children: [
                  _settingTile(Icons.dark_mode_outlined, 'Display Theme', 'Obsidian OLED (Active)'),
                  const Divider(color: AppColors.glassBorder, height: 20),
                  _settingTile(Icons.monetization_on_outlined, 'Base Currency', 'USD (\$)'),
                  const Divider(color: AppColors.glassBorder, height: 20),
                  _settingTile(Icons.fingerprint, 'Biometric Lock', 'Enabled'),
                  const Divider(color: AppColors.glassBorder, height: 20),
                  _settingTile(Icons.info_outline, 'Platform Version', 'v2.4.0 Artefakt Edition'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingTile(IconData icon, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.neonCyan, size: 20),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
        Text(value, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
      ],
    );
  }
}
