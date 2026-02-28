import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/src/repository/thai_address_repository.dart';
import 'package:thai_address_picker/src/widgets/village_autocomplete.dart';

import '../helpers/fake_asset_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ThaiAddressRepository repository;
  final fakeBundle = FakeAssetBundle();

  setUpAll(() async {
    repository = ThaiAddressRepository();
    await repository.initialize(bundle: fakeBundle, useIsolate: false);
  });

  Widget createSubject({
    dynamic onSelected,
    TextEditingController? controller,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: VillageAutocomplete(
          repository: repository,
          onSuggestionSelected: onSelected,
          controller: controller,
          useThai: true,
        ),
      ),
    );
  }

  testWidgets('renders TextField', (tester) async {
    await tester.pumpWidget(createSubject());
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('shows suggestions when typing', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.enterText(find.byType(TextField), 'บ้าน');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.textContaining('บ้านทดสอบ'), findsAtLeastNWidgets(1));
  });

  testWidgets('selects suggestion triggers callback', (tester) async {
    dynamic selected;
    await tester.pumpWidget(createSubject(onSelected: (val) => selected = val));

    await tester.enterText(find.byType(TextField), 'บ้าน');
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('บ้านทดสอบ').first);
    await tester.pumpAndSettle();

    expect(selected, isNotNull);
    // VillageSuggestion has .village field
    expect(selected.village.nameTh, contains('บ้านทดสอบ'));
  });

  testWidgets('uses external controller if provided', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(createSubject(controller: controller));

    await tester.enterText(find.byType(TextField), 'Hello');
    expect(controller.text, 'Hello');
  });
}
