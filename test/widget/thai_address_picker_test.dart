import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

import '../helpers/fake_asset_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ThaiAddressRepository repository;
  final fakeBundle = FakeAssetBundle();

  setUpAll(() async {
    repository = ThaiAddressRepository();
    await repository.initialize(bundle: fakeBundle, useIsolate: false);
  });

  Widget createSubject(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('ThaiAddressPicker', () {
    testWidgets('showBottomSheet opens bottom sheet and confirms', (
      tester,
    ) async {
      final p = repository.provinces.first;

      await tester.pumpWidget(
        createSubject(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  final _ = await ThaiAddressPicker.showBottomSheet(
                    context: context,
                    repository: repository,
                    useThai: true,
                    initialAddress: ThaiAddress(
                      provinceTh: p.nameTh,
                      provinceId: p.id,
                    ),
                  );
                  // Store result to verify?
                  // Usually we can't easily extract result unless we dump it to a widget or verify state logic.
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap Province Dropdown (first one)
      await tester.tap(find.byType(DropdownButtonFormField<Province>).first);
      await tester.pumpAndSettle();

      // Select P1 (from FakeAssetBundle)
      await tester.tap(find.text('P1').last);
      await tester.pumpAndSettle();

      // Now _currentAddress should be set (partial address is allowed?
      // _notifyChange converts state to ThaiAddress. Yes.)

      await tester.tap(find.text('ยืนยัน')); // Confirm
      await tester.pumpAndSettle(); // Should close
      expect(find.text('เลือกที่อยู่'), findsNothing);
    });

    testWidgets('showDialog and cancel', (tester) async {
      await tester.pumpWidget(
        createSubject(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  ThaiAddressPicker.showDialog(
                    context: context,
                    repository: repository,
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);

      await tester.tap(find.text('ยกเลิก'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
    });
  });
}
