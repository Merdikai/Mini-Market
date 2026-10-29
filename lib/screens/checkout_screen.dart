import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/tilt_card_3d.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showBackOfCard = false;

  final _nameCtrl = TextEditingController(text: 'Alexandre Mercer');
  final _addressCtrl = TextEditingController(text: '742 Evergreen Terrace, Sector 7');
  final _cityCtrl = TextEditingController(text: 'Neo Geneva');
  final _cardNumCtrl = TextEditingController(text: '•••• •••• •••• 4289');

  int _selectedDeliveryMethod = 1; // 0: Standard, 1: Drone Priority, 2: Concierge

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _cardNumCtrl.dispose();
    super.dispose();
  }

  void _toggleCardFlip() {
    if (_showBackOfCard) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _showBackOfCard = !_showBackOfCard);
  }

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
          'SECURE CHECKOUT',
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
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Interactive 3D Credit Card (Flippable)
            Center(
              child: GestureDetector(
                onTap: _toggleCardFlip,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final isFront = _flipAnimation.value < (math.pi / 2);
                    return Transform(
                      alignment: FractionalOffset.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002)
                        ..rotateY(_flipAnimation.value),
                      child: TiltCard3D(
                        maxTiltAngle: 0.16,
                        child: isFront
                            ? _buildCardFront(store)
                            : Transform(
                                alignment: FractionalOffset.center,
                                transform: Matrix4.identity()..rotateY(math.pi),
                                child: _buildCardBack(),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'TAP CARD TO FLIP SECURITY CODE',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // 2. Shipping Address Section
            const Text(
              'SHIPPING DESTINATION',
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
                  _buildInput('Full Recipient Name', _nameCtrl, Icons.person_outline),
                  const SizedBox(height: 12),
                  _buildInput('Street Address / Sector', _addressCtrl, Icons.location_on_outlined),
                  const SizedBox(height: 12),
                  _buildInput('City & Postal Matrix', _cityCtrl, Icons.apartment_outlined),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // 3. Delivery Method Tier
            const Text(
              'DISPATCH SPEED',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            _buildDeliveryOption(
              0,
              'Standard Orbital',
              '3-5 Business Cycles',
              'FREE',
              Icons.local_shipping_outlined,
            ),
            const SizedBox(height: 10),
            _buildDeliveryOption(
              1,
              'Autonomous Drone Priority',
              'Next-Morning Guaranteed Delivery',
              '\$25',
              Icons.flight_takeoff_outlined,
            ),
            const SizedBox(height: 10),
            _buildDeliveryOption(
              2,
              'White Glove Concierge',
              'Same-Day Hand Delivery & Inspection',
              '\$75',
              Icons.shield_outlined,
            ),
            const SizedBox(height: 28),

            // 4. Order Summary Card
            GlassContainer(
              padding: const EdgeInsets.all(18),
              borderRadius: 18,
              backgroundColor: AppColors.surfaceElevated.withValues(alpha: 0.7),
              child: Column(
                children: [
                  _summaryRow('Subtotal', '\$${store.cartSubtotal.toStringAsFixed(0)}'),
                  if (store.appliedDiscount > 0)
                    _summaryRow(
                      'Promotional Discount (${(store.appliedDiscount * 100).toInt()}%)',
                      '-\$${(store.cartSubtotal * store.appliedDiscount).toStringAsFixed(0)}',
                      color: AppColors.cyberEmerald,
                    ),
                  _summaryRow(
                    'Dispatch Tier',
                    _selectedDeliveryMethod == 0 ? 'FREE' : (_selectedDeliveryMethod == 1 ? '\$25' : '\$75'),
                  ),
                  const Divider(color: AppColors.glassBorder, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payable',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${(store.cartTotal + (_selectedDeliveryMethod == 0 ? 0 : (_selectedDeliveryMethod == 1 ? 25 : 75))).toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.neonCyan,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        color: AppColors.surfaceElevated,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
              foregroundColor: AppColors.obsidian,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              store.placeOrder();
              _showOrderSuccess(context);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 18),
                SizedBox(width: 8),
                Text(
                  'AUTHORIZE & CONFIRM ORDER',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront(StoreProvider store) {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2235), Color(0xFF0F121C), Color(0xFF161B2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.2),
            blurRadius: 28,
            offset: const Offset(0, 10),
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
                  Icon(Icons.nfc, color: AppColors.neonCyan, size: 26),
                  SizedBox(width: 10),
                  Text(
                    'MINI MARKET VIP',
                    style: TextStyle(
                      color: AppColors.neonCyan,
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
                  gradient: AppColors.luxuryGold,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PLATINUM',
                  style: TextStyle(
                    color: AppColors.obsidian,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const Text(
            '••••  ••••  ••••  4289',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.5,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CARDHOLDER', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
                  Text(_nameCtrl.text.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('EXPIRES', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
                  Text('08/29', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF141724),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.glassBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Container(
            height: 40,
            width: double.infinity,
            color: Colors.black,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 140,
                  height: 32,
                  color: Colors.white24,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 8),
                  child: const Text(
                    'CVC: 892',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                  ),
                ),
                const Icon(Icons.verified_user_outlined, color: AppColors.cyberEmerald, size: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.neonCyan, size: 20),
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDeliveryOption(int index, String title, String subtitle, String price, IconData icon) {
    final isSelected = _selectedDeliveryMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedDeliveryMethod = index),
      child: GlassContainer(
        padding: const EdgeInsets.all(14),
        borderRadius: 16,
        backgroundColor: isSelected
            ? AppColors.surfaceElevated
            : AppColors.surfaceDark.withValues(alpha: 0.5),
        border: Border.all(
          color: isSelected ? AppColors.neonCyan : AppColors.glassBorder,
          width: isSelected ? 1.5 : 1,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.neonCyan : AppColors.textMuted, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                color: isSelected ? AppColors.neonCyan : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: TextStyle(color: color ?? Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showOrderSuccess(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.cyberEmerald, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.cyberEmerald.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cyberEmerald, width: 2),
                ),
                child: const Icon(Icons.check, color: AppColors.cyberEmerald, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'ORDER CONFIRMED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your luxury artifact is entering fabrication and autonomous dispatch queue.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyberEmerald,
                    foregroundColor: AppColors.obsidian,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('RETURN TO CATALOG', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
