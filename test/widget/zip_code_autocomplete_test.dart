import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/src/providers/thai_address_providers.dart';
import 'package:thai_address_picker/src/repository/thai_address_repository.dart';
import 'package:thai_address_picker/src/widgets/zip_code_autocomplete.dart';

import '../helpers/fake_asset_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ThaiAddressRepository repository;
  final fakeBundle = FakeAssetBundle();

  setUpAll(() async {
    repository = ThaiAddressRepository();
    await repository.initialize(bundle: fakeBundle, useIsolate: false);
  });

  Widget createSubject({ValueChanged<String>? onSelected}) {
    return ProviderScope(
      overrides: [thaiAddressRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        home: Scaffold(
          body: ZipCodeAutocomplete(onZipCodeSelected: onSelected),
        ),
      ),
    );
  }

  testWidgets('renders TextField', (tester) async {
    await tester.pumpWidget(createSubject());
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('typing numbers shows suggestions', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.enterText(find.byType(TextField), '10');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Should show suggestion for 10200 (from SD1)
    expect(find.text('10200'), findsOneWidget);

    // Verify subtitle text (en name) matches
    // SD1 -> District 1001 (D1) -> Province 1 (P1)
    // Display text logic usually creates nice string
  });

  testWidgets('selects suggestion and updates state', (tester) async {
    dynamic selectedZip;
    await tester.pumpWidget(
      createSubject(onSelected: (val) => selectedZip = val),
    );

    await tester.enterText(find.byType(TextField), '102');
    await tester.pumpAndSettle();

    // Select 10200
    await tester.tap(find.text('10200').first);
    await tester.pumpAndSettle();

    expect(selectedZip, '10200');

    // Verify notifier state
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ZipCodeAutocomplete)),
    );
    final state = container.read(thaiAddressNotifierProvider);
    expect(state.zipCode, '10200');
    expect(state.selectedSubDistrict?.id, 100101);
  });

  testWidgets('clearing text resets state', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.enterText(find.byType(TextField), '102');
    await tester.pumpAndSettle();

    // Clear
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ZipCodeAutocomplete)),
    );
    final state = container.read(thaiAddressNotifierProvider);
    expect(state.zipCode, null);
    expect(state.selectedProvince, null);
  });
}
