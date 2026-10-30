import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/store_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/iphone_frame.dart';

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
    return MaterialApp(
      title: 'Mini Market — iPhone 16 Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.luxuryDarkTheme,
      home: const Scaffold(
        backgroundColor: Colors.black,
        body: IPhoneDeviceFrame(
          child: HomeScreen(),
        ),
      ),
    );
  }
}
