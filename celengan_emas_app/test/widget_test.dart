import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:celengan_emas_app/main.dart';
import 'package:celengan_emas_app/services/login.dart';
import 'package:celengan_emas_app/services/welcome_page.dart'
    as services_welcome;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (call) async => null,
      );

  testWidgets('app always opens on the welcome page', (tester) async {
    await tester.pumpWidget(const CelenganEmasApp());

    expect(find.byType(services_welcome.WelcomePage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('welcome page opens the login page without auto-login', (
    tester,
  ) async {
    await tester.pumpWidget(const CelenganEmasApp());

    await tester.tap(find.text('Masuk ke Akun'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });
}
