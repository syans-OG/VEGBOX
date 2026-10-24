import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vegbox/core/di/injection.dart';
import 'package:vegbox/profile_page.dart';
import 'package:vegbox/services/favorites_service.dart';

import 'support/app_test_harness.dart';

void main() {
  setUp(resetApp);

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('favorites are reachable from the profile', (tester) async {
    getIt<FavoritesService>().toggle(testVegetable);

    await tester.pumpWidget(
      appWith(
        Scaffold(
          body: ProfilePage(
            onOpenOrders: () {},
            onOpenCart: () {},
            onLoggedOut: () {},
          ),
        ),
      ),
    );

    final favoritesRow = find.text('Favorites');
    await tester.ensureVisible(favoritesRow);
    await tester.pumpAndSettle();

    expect(find.text('1 vegetable saved'), findsOneWidget);

    await tester.tap(favoritesRow);
    await tester.pumpAndSettle();

    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Bayam Hijau'), findsOneWidget);
    expect(find.text('1 vegetable saved'), findsOneWidget);
  });
}
