import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

import '../helpers/fake_asset_bundle.dart';

// A minimal IThaiAddressRepository implementation that always fails to init.
// Used to test the form's error state.
class _FailingRepository implements IThaiAddressRepository {
  @override
  bool get isInitialized => false;
  @override
  Future<void> initialize({AssetBundle? bundle, bool useIsolate = true}) =>
      Future.error('Simulated Error');
  @override
  void clearVillageCache() {}
  @override
  List<Geography> get geographies => throw UnimplementedError();
  @override
  List<Province> get provinces => throw UnimplementedError();
  @override
  List<District> get districts => throw UnimplementedError();
  @override
  List<SubDistrict> get subDistricts => throw UnimplementedError();
  @override
  Geography? getGeographyById(int id) => null;
  @override
  Province? getProvinceById(int id) => null;
  @override
  District? getDistrictById(int id) => null;
  @override
  SubDistrict? getSubDistrictById(int id) => null;
  @override
  List<Province> getProvincesByGeography(int geographyId) => [];
  @override
  List<District> getDistrictsByProvince(int provinceId) => [];
  @override
  List<SubDistrict> getSubDistrictsByDistrict(int districtId) => [];
  @override
  Future<List<Village>> getVillagesBySubDistrict(int subDistrictId) async => [];
  @override
  List<SubDistrict> getSubDistrictsByZipCode(String zipCode) => [];
  @override
  List<Province> searchProvinces(String query) => [];
  @override
  List<District> searchDistricts(String query, {int? provinceId}) => [];
  @override
  List<SubDistrict> searchSubDistricts(String query, {int? districtId}) => [];
  @override
  Future<List<VillageSuggestion>> searchVillages(
    String query, {
    int maxResults = 20,
  }) async => [];
  @override
  List<ZipCodeSuggestion> searchZipCodes(String query, {int maxResults = 20}) =>
      [];
  @override
  List<String> getAllZipCodes() => [];
  @override
  Map<String, dynamic> getFullAddressFromSubDistrict(SubDistrict subDistrict) =>
      {};
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThaiAddressRepository repository;
  ThaiAddressController ctrl = ThaiAddressController(
    repository: ThaiAddressRepository(),
  );

  setUp(() async {
    ThaiAddressRepository().resetForTesting();
    repository = ThaiAddressRepository();
    await repository.initialize(bundle: FakeAssetBundle(), useIsolate: false);
    ctrl = ThaiAddressController(repository: repository);
    addTearDown(ctrl.dispose);
  });

  Widget createSubject({
    void Function(ThaiAddress)? onChanged,
    bool enabled = true,
    ThaiAddressLabels? labels,
    bool useThai = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ThaiAddressForm(
            controller: ctrl,
            onChanged: onChanged,
            enabled: enabled,
            labels: labels,
            useThai: useThai,
          ),
        ),
      ),
    );
  }

  testWidgets('ThaiAddressForm loads and displays form', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    expect(find.byType(ThaiAddressForm), findsOneWidget);
    expect(
      find.byType(DropdownButtonFormField<Province>),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('ThaiAddressForm shows error on init failure', (tester) async {
    final failCtrl = ThaiAddressController(repository: _FailingRepository());
    addTearDown(failCtrl.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ThaiAddressForm(controller: failCtrl)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Error loading data'), findsOneWidget);
  });

  testWidgets('ThaiAddressForm calls onChanged logic only when enabled', (
    tester,
  ) async {
    await tester.pumpWidget(createSubject(enabled: false));
    await tester.pumpAndSettle();

    final dropdown = tester.widget<DropdownButtonFormField<Province>>(
      find.byType(DropdownButtonFormField<Province>).first,
    );
    expect(dropdown.onChanged, isNull);
  });

  testWidgets('ThaiAddressForm notifies on change', (tester) async {
    ThaiAddress? result;

    await tester.pumpWidget(
      createSubject(onChanged: (val) => result = val, useThai: false),
    );
    await tester.pumpAndSettle();

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
    final p = repository.provinces.first;
    final d = repository.districts.first;
    final s = repository.subDistricts.first;

    // Seed the controller with initial values before building the form
    ctrl.selectProvince(p);
    ctrl.selectDistrict(d);
    ctrl.selectSubDistrict(s);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: ThaiAddressForm(controller: ctrl)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('P1'), findsOneWidget);
    expect(find.text('D1'), findsOneWidget);
    expect(find.text('SD1'), findsOneWidget);
    expect(find.text('10200'), findsOneWidget);
  });

  testWidgets('ThaiAddressForm disposes safely', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();
  });

  testWidgets(
    'ThaiAddressForm updates zip code when state changes externally',
    (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final p = repository.provinces.first;
      final d = repository.districts.first;
      final s = repository.subDistricts.first;

      ctrl.selectProvince(p);
      ctrl.selectDistrict(d);
      await tester.pumpAndSettle();

      ctrl.selectSubDistrict(s);
      await tester.pumpAndSettle();

      expect(find.text('10200'), findsOneWidget);

      ctrl.reset();
      await tester.pumpAndSettle();

      expect(find.text('10200'), findsNothing);
    },
  );

  testWidgets('ThaiAddressForm works without onChanged callback', (
    tester,
  ) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<Province>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('P1').last);
    await tester.pumpAndSettle();
  });
}
