import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/src/providers/thai_address_providers.dart';
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
    ValueChanged<dynamic>? onSelected,
    TextEditingController? controller,
  }) {
    return ProviderScope(
      overrides: [thaiAddressRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        home: Scaffold(
          body: VillageAutocomplete(
            onVillageSelected: onSelected,
            controller: controller,
            useThai: true, // Only Thai supported for village now?
          ),
        ),
      ),
    );
  }

  testWidgets('renders TextField', (tester) async {
    await tester.pumpWidget(createSubject());
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('shows suggestions when typing', (tester) async {
    // Village data: id: 1, nameTh: "บ้านทดสอบ", nameEn: "Baan Test"
    // So typing "บ้าน" should match.

    await tester.pumpWidget(createSubject());
    await tester.enterText(find.byType(TextField), 'บ้าน');
    await tester.pump();
    await tester.pump(
      const Duration(milliseconds: 300),
    ); // Debounce? Wait, repository search is sync? Not usually but Autocomplete might have delay.

    // Autocomplete runs optionsBuilder.
    // fake_asset_bundle has Village(nameTh: "บ้านทดสอบ", nameEn: "Baan Test", moo: 1, ...)
    // So "บ้าน" should match.

    await tester.pumpAndSettle();

    // Suggestion is expected to be visible
    expect(find.textContaining('บ้านทดสอบ'), findsAtLeastNWidgets(1));
  });

  testWidgets('selects suggestion triggers callback', (tester) async {
    dynamic selected;
    await tester.pumpWidget(createSubject(onSelected: (val) => selected = val));

    await tester.enterText(find.byType(TextField), 'บ้าน');
    await tester.pumpAndSettle();

    // Tap the first suggestion
    await tester.tap(find.textContaining('บ้านทดสอบ').first);
    await tester.pumpAndSettle();

    expect(selected, isNotNull);
    // Expect either of our test villages
    expect(selected.nameTh, contains('บ้านทดสอบ'));

    // Check if notifier updated
    final container = ProviderScope.containerOf(
      tester.element(find.byType(VillageAutocomplete)),
    );
    final state = container.read(thaiAddressNotifierProvider);
    // Fake data: Village linked to SubDistrict 100101 -> District 1001 -> Province 1
    expect(state.selectedProvince?.id, 1);
    expect(state.selectedDistrict?.id, 1001);
    expect(state.selectedSubDistrict?.id, 100101);
  });

  testWidgets('uses external controller if provided', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(createSubject(controller: controller));

    await tester.enterText(find.byType(TextField), 'Hello');
    expect(controller.text, 'Hello');
  });
}
