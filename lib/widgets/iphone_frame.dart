import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Photorealistic iPhone 16 Pro device frame enclosure for Flutter
class IPhoneDeviceFrame extends StatelessWidget {
  final Widget child;
  final bool enableFrame;

  const IPhoneDeviceFrame({
    super.key,
    required this.child,
    this.enableFrame = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enableFrame) return child;

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          width: 395,
          height: 820,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF383B44),
                Color(0xFF22242B),
                Color(0xFF141519),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(56),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.85),
                blurRadius: 50,
                spreadRadius: 8,
                offset: const Offset(0, 20),
              ),
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha: 0.15),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(46),
            child: Container(
              color: AppColors.obsidian,
              child: Stack(
                children: [
                  // App Viewport Content
                  Positioned.fill(
                    top: 48,
                    bottom: 24,
                    child: child,
                  ),

                  // iOS Top Dynamic Island & Status Bar Header
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 48,
                    child: Container(
                      color: AppColors.obsidian,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Time (9:41)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '9:41',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),

                          // Dynamic Island Pill
                          Container(
                            width: 110,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                                width: 0.8,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppColors.neonCyan,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'ORA',
                                      style: TextStyle(
                                        color: AppColors.neonCyan,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: AppColors.cyberEmerald,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Wi-Fi & Battery Status
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.wifi, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Container(
                                  width: 20,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 1),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  padding: const EdgeInsets.all(1),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(1.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // iOS Bottom Home Indicator Bar
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 24,
                    child: Container(
                      alignment: Alignment.center,
                      color: AppColors.obsidian,
                      child: Container(
                        width: 130,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
