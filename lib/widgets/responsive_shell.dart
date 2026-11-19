import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import 'iphone_frame.dart';

class ResponsiveShell extends StatelessWidget {
  final Widget child;

  const ResponsiveShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();
    final isDemoFrameEnabled = provider.settings.isDemoFrameVisible;

    // If demo frame is enabled, wrap in iPhone device frame
    if (isDemoFrameEnabled) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: IPhoneDeviceFrame(
          child: child,
        ),
      );
    }

    // Native responsive full screen
    return child;
  }
}
