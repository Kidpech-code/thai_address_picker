import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

import '../helpers/fake_asset_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ThaiAddressRepository repository;
  final fakeBundle = FakeAssetBundle();

  setUpAll(() async {
    ThaiAddressRepository().resetForTesting();
    repository = ThaiAddressRepository();
    await repository.initialize(bundle: fakeBundle, useIsolate: false);
  });

  Widget createSubject({bool enabled = true, Province? initialProvince}) {
    final ctrl = ThaiAddressController(repository: repository);
    if (initialProvince != null) ctrl.selectProvince(initialProvince);
    return MaterialApp(
      home: Scaffold(
        body: ThaiAddressForm(controller: ctrl, enabled: enabled),
      ),
    );
  }

  testWidgets('renders all dropdowns', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    expect(find.text('จังหวัด'), findsOneWidget);
    expect(find.text('อำเภอ/เขต'), findsOneWidget);
    expect(find.text('ตำบล/แขวง'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('selecting subdistrict updates zip code', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<Province>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('P1').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<District>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('D1').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<SubDistrict>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('SD1').last);
    await tester.pumpAndSettle();

    expect(find.text('10200'), findsOneWidget);
  });

  testWidgets('disabled form has null onChanged', (tester) async {
    await tester.pumpWidget(createSubject(enabled: false));
    await tester.pumpAndSettle();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.enabled, false);
  });
}
