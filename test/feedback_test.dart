import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vegbox/ui/widgets/feedback.dart';

class _SnackBarHost extends StatelessWidget {
  const _SnackBarHost();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () => showAppSnackBar(
              context,
              'Added to cart',
              actionLabel: 'View cart',
              onAction: () {},
            ),
            child: const Text('Show snackbar'),
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('snackbar with an action hides automatically', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(accessibleNavigation: true),
          child: child!,
        ),
        home: const _SnackBarHost(),
      ),
    );

    await tester.tap(find.text('Show snackbar'));
    await tester.pump();

    expect(find.text('Added to cart'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Added to cart'), findsNothing);
  });

  testWidgets('snackbars queue instead of replacing each other', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(accessibleNavigation: true),
          child: child!,
        ),
        home: const _SnackBarHost(),
      ),
    );

    await tester.tap(find.text('Show snackbar'));
    await tester.pump();
    await tester.tap(find.text('Show snackbar'));
    await tester.pump();

    expect(find.text('Added to cart'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Added to cart'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Added to cart'), findsNothing);
  });
}
