import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

import '../helpers/fake_asset_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createSubject({
    void Function(ThaiAddress)? onChanged,
    bool enabled = true,
    ThaiAddressLabels? labels,
    bool useThai = true,
  }) {
    return ProviderScope(
      overrides: [
        // Override global provider if needed, but usually we rely on repository being mocked
        // However, the form uses repositoryInitProvider which calls repository.initialize.
        // We should ensure repository uses our FakeAssetBundle.
        // Since repository is singleton, we must configure it before pump.
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ThaiAddressForm(
              onChanged: onChanged,
              enabled: enabled,
              labels: labels,
              useThai: useThai,
            ),
          ),
        ),
      ),
    );
  }

  setUp(() {
    ThaiAddressRepository().resetForTesting();
  });

  testWidgets('ThaiAddressForm loads and displays form', (tester) async {
    await ThaiAddressRepository().initialize(
      bundle: FakeAssetBundle(),
      useIsolate: false,
    );

    await tester.pumpWidget(createSubject());
    // Pump until future completes
    await tester.pumpAndSettle();

    // Should be loaded
    expect(find.byType(ThaiAddressForm), findsOneWidget);
    // Use findsWidgets because there are multiple fields
    expect(
      find.byType(DropdownButtonFormField<Province>),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('ThaiAddressForm shows error on init failure', (tester) async {
    // Override provider to simulate error
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryInitProvider.overrideWith(
            (ref) => Future.error('Simulated Error'),
          ),
        ],
        child: MaterialApp(home: Scaffold(body: ThaiAddressForm())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Simulated Error'), findsOneWidget);
  });

  testWidgets('ThaiAddressForm calls onChanged logic only when enabled', (
    tester,
  ) async {
    await ThaiAddressRepository().initialize(
      bundle: FakeAssetBundle(),
      useIsolate: false,
    );

    await tester.pumpWidget(createSubject(enabled: false));
    await tester.pumpAndSettle();

    final dropdown = tester.widget<DropdownButtonFormField<Province>>(
      find.byType(DropdownButtonFormField<Province>).first,
    );
    expect(dropdown.onChanged, isNull);
  });

  testWidgets('ThaiAddressForm notifies on change', (tester) async {
    await ThaiAddressRepository().initialize(
      bundle: FakeAssetBundle(),
      useIsolate: false,
    );
    ThaiAddress? result;

    await tester.pumpWidget(
      createSubject(onChanged: (val) => result = val, useThai: false),
    );
    await tester.pumpAndSettle();

    // Select Province
    await tester.tap(find.byType(DropdownButtonFormField<Province>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('P1_EN').last);
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result?.provinceEn, 'P1_EN');
  });

  testWidgets('ThaiAddressForm initializes with initial values', (
    tester,
  ) async {
    await ThaiAddressRepository().initialize(
      bundle: FakeAssetBundle(),
      useIsolate: false,
    );
    final repo = ThaiAddressRepository();
    final p = repo.provinces.first; // P1
    final d = repo.districts.first; // D1
    final s = repo.subDistricts.first; // SD1

    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryInitProvider.overrideWith((ref) async {})],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ThaiAddressForm(
                initialProvince: p,
                initialDistrict: d,
                initialSubDistrict: s,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check if dropdowns selected
    // Note: DropdownButtonFormField displays the selected item's child.
    // P1 -> "Province 1" (nameTh)
    // D1 -> "D1"
    // SD1 -> "SD1"
    // ZipCode -> "10200"

    expect(find.text('P1'), findsOneWidget); // Found in Province Dropdown
    expect(find.text('D1'), findsOneWidget);
    expect(find.text('SD1'), findsOneWidget);
    expect(find.text('10200'), findsOneWidget);
  });

  testWidgets('ThaiAddressForm disposes safely', (tester) async {
    await ThaiAddressRepository().initialize(
      bundle: FakeAssetBundle(),
      useIsolate: false,
    );
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    // Replace widget to trigger dispose
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();
  });

  testWidgets(
    'ThaiAddressForm updates zip code when state changes externally',
    (tester) async {
      await ThaiAddressRepository().initialize(
        bundle: FakeAssetBundle(),
        useIsolate: false,
      );

      // We need to access the provider container to modify state directly
      // So we can't use our helper directly if we need the container.
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(home: Scaffold(body: ThaiAddressForm())),
        ),
      );
      await tester.pumpAndSettle();

      // Force set zip code in notifier
      // We can't access notifier directly from here easily without exposing it.
      // But we can select subdistrict which sets zip code.
      final repo = ThaiAddressRepository();
      final p = repo.provinces.first;
      final d = repo.districts.first;
      final s = repo.subDistricts.first; // Should have zip 10200

      final notifier = container.read(thaiAddressNotifierProvider.notifier);

      // Changing province/district to setup
      notifier.selectProvince(p);
      notifier.selectDistrict(d);

      await tester.pumpAndSettle();

      // Now convert subdistrict selection
      // This should update text controller
      notifier.selectSubDistrict(s);
      await tester.pumpAndSettle();

      expect(find.text('10200'), findsOneWidget); // Should be in TextField

      // Clear zip code
      // notifier.clear(); // Error: method not defined
      notifier.reset();
      await tester.pumpAndSettle();

      // Should be empty
      expect(find.text('10200'), findsNothing);
    },
  );

  testWidgets('ThaiAddressForm works without onChanged callback', (
    tester,
  ) async {
    // Initialize repo
    await ThaiAddressRepository().initialize(
      bundle: FakeAssetBundle(),
      useIsolate: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryInitProvider.overrideWith((ref) async {})],
        child: MaterialApp(
          home: Scaffold(
            body: ThaiAddressForm(
              // No onChanged provided
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Select Province should not crash
    await tester.tap(find.byType(DropdownButtonFormField<Province>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('P1').last);
    await tester.pumpAndSettle();
  });
}
