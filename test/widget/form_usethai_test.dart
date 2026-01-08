import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/thai_address_picker.dart';
import '../helpers/fake_asset_bundle.dart';

void main() {
  setUpAll(() async {
    await ThaiAddressRepository().initialize(
      bundle: FakeAssetBundle(),
      useIsolate: false,
    );
  });

  testWidgets('ThaiAddressForm displays English names when useThai is false', (
    tester,
  ) async {
    final repo = ThaiAddressRepository();
    final p = repo.provinces.first;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryInitProvider.overrideWith((ref) async {})],
        child: MaterialApp(
          home: Scaffold(
            body: ThaiAddressForm(initialProvince: p, useThai: false),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Should find English name "P1_EN" not "P1"
    expect(find.text('P1_EN'), findsOneWidget);
    expect(find.text('P1'), findsNothing); // Ensure Thai name is NOT shown

    // Also check labels if possible? Labels might differ.
  });

  testWidgets('ThaiAddressForm uses custom decorations', (tester) async {
    final repo = ThaiAddressRepository();
    final p = repo.provinces.first;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryInitProvider.overrideWith((ref) async {})],
        child: MaterialApp(
          home: Scaffold(
            body: ThaiAddressForm(
              initialProvince: p,
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
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Custom Province'), findsOneWidget);
    expect(find.text('Custom District'), findsOneWidget);
    expect(find.text('Custom SubDistrict'), findsOneWidget);
    expect(find.text('Custom Zip'), findsOneWidget);
  });
}
