import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

import '../helpers/fake_asset_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ThaiAddressRepository repository;

  setUpAll(() async {
    repository = ThaiAddressRepository();
    // Ensure initialized
    await repository.initialize(bundle: FakeAssetBundle(), useIsolate: false);
  });

  Widget createSubject(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('showDialog opens dialog and cancels', (tester) async {
    await tester.pumpWidget(
      createSubject(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                await ThaiAddressPicker.showDialog(
                  context: context,
                  repository: repository,
                  useThai: true,
                );
              },
              child: const Text('Open Dialog'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('เลือกที่อยู่'), findsOneWidget); // Default Thai title

    // Tap Close button (onCancel)
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('showDialog confirms selection', (tester) async {
    ThaiAddress? result;
    await tester.pumpWidget(
      createSubject(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await ThaiAddressPicker.showDialog(
                  context: context,
                  repository: repository,
                  useThai: true,
                );
              },
              child: const Text('Open Dialog'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Tap Confirm (Wait, we need to select something first or Confirm does nothing)
    // Since _currentAddress is initially null and not synced with initialAddress (bug?),
    // we must select something.

    // Select Province
    await tester.tap(find.byType(DropdownButtonFormField<Province>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('P1').last); // Default Thai name
    await tester.pumpAndSettle();

    // Now tap Confirm
    await tester.tap(find.text('ยืนยัน'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(result, isNotNull);
    expect(result?.provinceTh, 'P1');
  });
}
