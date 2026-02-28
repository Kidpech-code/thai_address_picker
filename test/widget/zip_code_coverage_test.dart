import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/src/widgets/zip_code_autocomplete.dart';
import 'package:thai_address_picker/src/repository/thai_address_repository.dart';

import '../helpers/fake_asset_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ThaiAddressRepository repository;

  setUp(() async {
    ThaiAddressRepository().resetForTesting();
    repository = ThaiAddressRepository();
    await repository.initialize(bundle: FakeAssetBundle(), useIsolate: false);
  });

  Widget createSubject({TextEditingController? controller}) {
    return MaterialApp(
      home: Scaffold(
        body: ZipCodeAutocomplete(
          repository: repository,
          controller: controller,
        ),
      ),
    );
  }

  testWidgets('ZipCodeAutocomplete handles non-numeric input', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('ZipCodeAutocomplete syncs with external controller', (
    tester,
  ) async {
    final controller = TextEditingController();
    await tester.pumpWidget(createSubject(controller: controller));
    await tester.enterText(find.byType(TextField), '123');
    await tester.pump();
    expect(controller.text, '123');
    controller.text = '456';
    await tester.pump();
    expect(find.text('456'), findsOneWidget);
  });

  testWidgets('ZipCodeAutocomplete internal controller dispose coverage', (
    tester,
  ) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpWidget(Container());
  });

  testWidgets('ZipCodeAutocomplete external controller dispose coverage', (
    tester,
  ) async {
    final controller = TextEditingController();
    await tester.pumpWidget(createSubject(controller: controller));
    await tester.pumpWidget(Container());
    controller.text = 'test';
  });
}
