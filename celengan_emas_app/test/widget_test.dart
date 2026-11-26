import 'package:flutter_test/flutter_test.dart';

import 'package:celengan_emas_app/main.dart';
import 'package:celengan_emas_app/services/login.dart';

void main() {
  testWidgets('app always opens on the welcome page', (WidgetTester tester) async {
    await tester.pumpWidget(const CelenganEmasApp());

    expect(find.byType(WelcomePage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('welcome page opens the login page without auto-login', (WidgetTester tester) async {
    await tester.pumpWidget(const CelenganEmasApp());

    await tester.tap(find.text('Masuk ke Akun →'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });
}
