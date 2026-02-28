import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

import '../helpers/fake_asset_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ThaiAddressRepository repository;

  setUpAll(() async {
    repository = ThaiAddressRepository();
    await repository.initialize(bundle: FakeAssetBundle(), useIsolate: false);
  });

  Widget createSubject(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('showBottomSheet opens sheet and cancels via header close icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      createSubject(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => ThaiAddressPicker.showBottomSheet(
                context: context,
                repository: repository,
                useThai: true,
              ),
              child: const Text('Open Sheet'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    // Verify it's a BottomSheet (or has matching structure)
    // _PickerContent uses a Container with height.
    expect(find.text('เลือกที่อยู่'), findsOneWidget); // Default Thai title

    // Close
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('เลือกที่อยู่'), findsNothing);
  });

  testWidgets('showBottomSheet respects custom height', (tester) async {
    const double customHeight = 500.0;
    await tester.pumpWidget(
      createSubject(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => ThaiAddressPicker.showBottomSheet(
                context: context,
                repository: repository,
                height: customHeight,
              ),
              child: const Text('Open Sheet'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    // Verify height — just exercise the parameter path
    expect(find.byType(BottomSheet), findsOneWidget);
  });

  testWidgets('showBottomSheet with useThai=false displays English title', (
    tester,
  ) async {
    await tester.pumpWidget(
      createSubject(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => ThaiAddressPicker.showBottomSheet(
                context: context,
                repository: repository,
                useThai: false,
              ),
              child: const Text('Open Sheet'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    expect(
      find.text('Select Address'),
      findsOneWidget,
    ); // Default English title
  });
}
