import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/thai_address_picker.dart';
import '../helpers/fake_asset_bundle.dart';

void main() {
  late ThaiAddressRepository repo;

  setUpAll(() async {
    ThaiAddressRepository().resetForTesting();
    repo = ThaiAddressRepository();
    await repo.initialize(bundle: FakeAssetBundle(), useIsolate: false);
  });

  testWidgets('ThaiAddressForm displays English names when useThai is false', (
    tester,
  ) async {
    final p = repo.provinces.first;
    final ctrl = ThaiAddressController(repository: repo);
    ctrl.selectProvince(p);
    addTearDown(ctrl.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ThaiAddressForm(controller: ctrl, useThai: false)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('P1_EN'), findsOneWidget);
    expect(find.text('P1'), findsNothing);
  });

  testWidgets('ThaiAddressForm uses custom decorations', (tester) async {
    final p = repo.provinces.first;
    final ctrl = ThaiAddressController(repository: repo);
    ctrl.selectProvince(p);
    addTearDown(ctrl.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ThaiAddressForm(
            controller: ctrl,
            provinceDecoration: const InputDecoration(
              labelText: 'Custom Province',
              border: OutlineInputBorder(),
            ),
            districtDecoration: const InputDecoration(
              labelText: 'Custom District',
            ),
            subDistrictDecoration: const InputDecoration(
              labelText: 'Custom SubDistrict',
            ),
            zipCodeDecoration: const InputDecoration(labelText: 'Custom Zip'),
            textStyle: const TextStyle(fontSize: 20, color: Colors.blue),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Custom Province'), findsOneWidget);
    expect(find.text('Custom District'), findsOneWidget);
    expect(find.text('Custom SubDistrict'), findsOneWidget);
    expect(find.text('Custom Zip'), findsOneWidget);
  });
}
