import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_market/main.dart';
import 'package:mini_market/providers/store_provider.dart';
import 'package:provider/provider.dart';

// 1x1 transparent PNG bytes for mock network responses during testing
final List<int> _kTransparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _createMockHttpClient();
  }
}

HttpClient _createMockHttpClient() {
  final client = _MockHttpClient();
  return client;
}

class _MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getUrl || invocation.memberName == #openUrl) {
      return Future<_MockHttpClientRequest>.value(_MockHttpClientRequest());
    }
    return super.noSuchMethod(invocation);
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #close) {
      return Future<_MockHttpClientResponse>.value(_MockHttpClientResponse());
    }
    return super.noSuchMethod(invocation);
  }
}

class _MockHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  int get contentLength => _kTransparentImage.length;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #listen) {
      return Stream<List<int>>.fromIterable([_kTransparentImage])
          .listen(invocation.positionalArguments[0] as void Function(List<int>)?);
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  testWidgets('Mini Market enterprise app loads with navigation hub and POS register', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => StoreProvider(),
        child: const MiniMarketApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify navigation tabs
    expect(find.text('POS Register'), findsOneWidget);
    expect(find.text('Inventory'), findsOneWidget);
    expect(find.text('Reports & P&L'), findsOneWidget);
    expect(find.text('Shift Drawer'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Verify POS terminal elements
    expect(find.text('Produce'), findsWidgets);
    expect(find.text('Beverages'), findsWidgets);
  });
}
