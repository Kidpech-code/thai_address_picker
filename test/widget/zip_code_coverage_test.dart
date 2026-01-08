import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/src/widgets/zip_code_autocomplete.dart';
import 'package:thai_address_picker/src/repository/thai_address_repository.dart';

import '../helpers/fake_asset_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createSubject({TextEditingController? controller}) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(body: ZipCodeAutocomplete(controller: controller)),
      ),
    );
  }

  setUp(() async {
    await ThaiAddressRepository().initialize(
      bundle: FakeAssetBundle(),
      useIsolate: false,
    );
  });

  testWidgets('ZipCodeAutocomplete handles non-numeric input', (tester) async {
    await tester.pumpWidget(createSubject());

    await tester.enterText(find.byType(TextField), 'abc');
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsNothing); // No options
  });

  testWidgets('ZipCodeAutocomplete syncs with external controller', (
    tester,
  ) async {
    final controller = TextEditingController();
    await tester.pumpWidget(createSubject(controller: controller));

    // Type in TextField -> Updates Controller
    await tester.enterText(find.byType(TextField), '123');
    await tester.pump();
    expect(controller.text, '123');

    // Update Controller -> Updates TextField
    controller.text = '456';
    // We need to trigger listeners.
    // Setting .text notifies listeners.
    await tester.pump();
    expect(find.text('456'), findsOneWidget);
  });

  testWidgets('ZipCodeAutocomplete internal controller dispose coverage', (
    tester,
  ) async {
    // Just run it to cover lines
    await tester.pumpWidget(createSubject());
    await tester.pumpWidget(Container());
  });

  testWidgets('ZipCodeAutocomplete external controller dispose coverage', (
    tester,
  ) async {
    final controller = TextEditingController();
    await tester.pumpWidget(createSubject(controller: controller));
    await tester.pumpWidget(Container());
    // Controller should still be usable (not disposed)
    controller.text = 'test';
  });
}
