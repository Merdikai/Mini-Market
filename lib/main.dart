import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/store_provider.dart';
import 'screens/main_navigation_hub.dart';
import 'theme/app_theme.dart';
import 'widgets/responsive_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => StoreProvider(),
      child: const MiniMarketApp(),
    ),
  );
}

class MiniMarketApp extends StatelessWidget {
  const MiniMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();

    return MaterialApp(
      title: 'Mini Market Retail Enterprise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.executiveLightTheme,
      darkTheme: AppTheme.luxuryDarkTheme,
      themeMode: store.settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const ResponsiveShell(
        child: MainNavigationHub(),
      ),
    );
  }
}
