import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vegbox/core/di/injection.dart';
import 'package:vegbox/notifications_page.dart';
import 'package:vegbox/ui/widgets/app_button.dart';
import 'package:vegbox/ui/widgets/favorite_button.dart';

import 'support/app_test_harness.dart';

void main() {
  setUp(resetApp);

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('favorite button exposes its toggled state', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      appWith(
        Scaffold(
          body: Center(
            child: FavoriteButton(
              isFavorite: false,
              onPressed: () {},
              name: 'Bayam Hijau',
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byType(FavoriteButton)),
      matchesSemantics(
        label: 'Save Bayam Hijau to favorites',
        isButton: true,
        isEnabled: true,
        hasEnabledState: true,
        hasToggledState: true,
        isToggled: false,
        hasTapAction: true,
      ),
    );

    handle.dispose();
  });

  testWidgets('app button exposes enabled and disabled states', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      appWith(
        Scaffold(
          body: Column(
            children: [
              AppButton(label: 'Checkout', onPressed: () {}),
              const AppButton(label: 'Unavailable'),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byType(AppButton).first),
      matchesSemantics(
        label: 'Checkout',
        isButton: true,
        isEnabled: true,
        hasEnabledState: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.byType(AppButton).last),
      matchesSemantics(
        label: 'Unavailable',
        isButton: true,
        isEnabled: false,
        hasEnabledState: true,
      ),
    );

    handle.dispose();
  });

  testWidgets('unread notifications announce their status', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(appWith(const Scaffold(body: NotificationsPage())));

    final tile = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          (widget.properties.label?.contains('Pay Day is here') ?? false),
    );
    expect(tile, findsOneWidget);

    final data = tester.getSemantics(tile).getSemanticsData();
    expect(data.label, contains('Unread'));
    expect(data.flagsCollection.isButton, isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);

    handle.dispose();
  });
}
