import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
    return MaterialApp(
      home: Scaffold(
        body: ZipCodeAutocomplete(
          repository: repository,
          onSuggestionSelected: onSelected != null
              ? (suggestion) => onSelected(suggestion.zipCode)
              : null,
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
    expect(find.text('10200'), findsOneWidget);
  });

  testWidgets('selects suggestion and updates callback', (tester) async {
    String? selectedZip;
    await tester.pumpWidget(
      createSubject(onSelected: (val) => selectedZip = val),
    );
    await tester.enterText(find.byType(TextField), '102');
    await tester.pumpAndSettle();
    await tester.tap(find.text('10200').first);
    await tester.pumpAndSettle();
    expect(selectedZip, '10200');
  });

  testWidgets('clearing text calls onCleared callback', (tester) async {
    bool cleared = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ZipCodeAutocomplete(
            repository: repository,
            onCleared: () => cleared = true,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), '102');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    expect(cleared, isTrue);
  });
}
