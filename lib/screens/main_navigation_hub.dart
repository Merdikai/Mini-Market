import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'inventory/product_catalog_screen.dart';
import 'pos/pos_terminal_screen.dart';
import 'reports/reports_dashboard_screen.dart';
import 'settings/settings_screen.dart';
import 'shifts/shift_management_screen.dart';

class MainNavigationHub extends StatefulWidget {
  const MainNavigationHub({super.key});

  @override
  State<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends State<MainNavigationHub> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    POSTerminalScreen(),
    ProductCatalogScreen(),
    ReportsDashboardScreen(),
    ShiftManagementScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidian : AppColors.lightBg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.glassBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          indicatorColor: (isDark ? AppColors.neonCyan : AppColors.brandPrimary).withValues(alpha: 0.15),
          destinations: [
            NavigationDestination(
              icon: Badge(
                isLabelVisible: store.cartItemCount > 0,
                label: Text('${store.cartItemCount}'),
                backgroundColor: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                textColor: isDark ? AppColors.obsidian : Colors.white,
                child: const Icon(Icons.point_of_sale_rounded),
              ),
              selectedIcon: Badge(
                isLabelVisible: store.cartItemCount > 0,
                label: Text('${store.cartItemCount}'),
                backgroundColor: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                textColor: isDark ? AppColors.obsidian : Colors.white,
                child: Icon(
                  Icons.point_of_sale_rounded,
                  color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                ),
              ),
              label: 'POS Register',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: store.lowStockProducts.isNotEmpty,
                label: Text('${store.lowStockProducts.length}'),
                backgroundColor: AppColors.alertOrange,
                child: const Icon(Icons.inventory_2_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: store.lowStockProducts.isNotEmpty,
                label: Text('${store.lowStockProducts.length}'),
                backgroundColor: AppColors.alertOrange,
                child: Icon(
                  Icons.inventory_2_rounded,
                  color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
                ),
              ),
              label: 'Inventory',
            ),
            NavigationDestination(
              icon: const Icon(Icons.analytics_outlined),
              selectedIcon: Icon(
                Icons.analytics_rounded,
                color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
              ),
              label: 'Reports & P&L',
            ),
            NavigationDestination(
              icon: const Icon(Icons.lock_clock_outlined),
              selectedIcon: Icon(
                Icons.lock_clock_rounded,
                color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
              ),
              label: 'Shift Drawer',
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: Icon(
                Icons.settings_rounded,
                color: isDark ? AppColors.neonCyan : AppColors.brandPrimary,
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
