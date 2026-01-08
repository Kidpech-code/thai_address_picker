import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/src/models/thai_address_labels.dart';

void main() {
  group('ThaiAddressLabels', () {
    test('should return custom labels when provided', () {
      const labels = ThaiAddressLabels(
        provinceLabel: 'P',
        districtLabel: 'D',
        subDistrictLabel: 'S',
        zipCodeLabel: 'Z',
        zipCodeHint: 'ZH',
        zipCodeHelper: 'ZHL',
        villageLabel: 'V',
        villageHint: 'VH',
        villageHelper: 'VHL',
        pickerTitle: 'T',
        confirmButton: 'C',
        cancelButton: 'Ca',
      );

      // Argument useThai shouldn't matter if custom label is provided
      expect(labels.getProvinceLabel(true), 'P');
      expect(labels.getDistrictLabel(false), 'D');
      expect(labels.getSubDistrictLabel(true), 'S');
      expect(labels.getZipCodeLabel(false), 'Z');
      expect(labels.getZipCodeHint(true), 'ZH');
      expect(labels.getZipCodeHelper(false), 'ZHL');
      expect(labels.getVillageLabel(true), 'V');
      expect(labels.getVillageHint(false), 'VH');
      expect(labels.getVillageHelper(true), 'VHL');
      expect(labels.getPickerTitle(false), 'T');
      expect(labels.getConfirmButton(true), 'C');
      expect(labels.getCancelButton(false), 'Ca');
    });

    test(
      'should return fallback Thai labels when null and useThai is true',
      () {
        const labels = ThaiAddressLabels();
        const thai = ThaiAddressLabels.thai;

        expect(labels.getProvinceLabel(true), thai.provinceLabel);
        expect(labels.getDistrictLabel(true), thai.districtLabel);
        expect(labels.getSubDistrictLabel(true), thai.subDistrictLabel);
        expect(labels.getZipCodeLabel(true), thai.zipCodeLabel);
        expect(labels.getZipCodeHint(true), thai.zipCodeHint);
        expect(labels.getZipCodeHelper(true), thai.zipCodeHelper);
        expect(labels.getVillageLabel(true), thai.villageLabel);
        expect(labels.getVillageHint(true), thai.villageHint);
        expect(labels.getVillageHelper(true), thai.villageHelper);
        expect(labels.getPickerTitle(true), thai.pickerTitle);
        expect(labels.getConfirmButton(true), thai.confirmButton);
        expect(labels.getCancelButton(true), thai.cancelButton);
      },
    );

    test(
      'should return fallback English labels when null and useThai is false',
      () {
        const labels = ThaiAddressLabels();
        const eng = ThaiAddressLabels.english;

        expect(labels.getProvinceLabel(false), eng.provinceLabel);
        expect(labels.getDistrictLabel(false), eng.districtLabel);
        expect(labels.getSubDistrictLabel(false), eng.subDistrictLabel);
        expect(labels.getZipCodeLabel(false), eng.zipCodeLabel);
        expect(labels.getZipCodeHint(false), eng.zipCodeHint);
        expect(labels.getZipCodeHelper(false), eng.zipCodeHelper);
        expect(labels.getVillageLabel(false), eng.villageLabel);
        expect(labels.getVillageHint(false), eng.villageHint);
        expect(labels.getVillageHelper(false), eng.villageHelper);
        expect(labels.getPickerTitle(false), eng.pickerTitle);
        expect(labels.getConfirmButton(false), eng.confirmButton);
        expect(labels.getCancelButton(false), eng.cancelButton);
      },
    );

    test('should copyWith all fields correctly', () {
      const original = ThaiAddressLabels(
        provinceLabel: 'Original',
        districtLabel: 'Original',
        subDistrictLabel: 'Original',
        zipCodeLabel: 'Original',
        zipCodeHint: 'Original',
        zipCodeHelper: 'Original',
        villageLabel: 'Original',
        villageHint: 'Original',
        villageHelper: 'Original',
        pickerTitle: 'Original',
        confirmButton: 'Original',
        cancelButton: 'Original',
      );

      final updated = original.copyWith(
        provinceLabel: 'Updated',
        districtLabel: 'Updated',
        subDistrictLabel: 'Updated',
        zipCodeLabel: 'Updated',
        zipCodeHint: 'Updated',
        zipCodeHelper: 'Updated',
        villageLabel: 'Updated',
        villageHint: 'Updated',
        villageHelper: 'Updated',
        pickerTitle: 'Updated',
        confirmButton: 'Updated',
        cancelButton: 'Updated',
      );

      expect(updated.provinceLabel, 'Updated');
      expect(updated.districtLabel, 'Updated');
      expect(updated.subDistrictLabel, 'Updated');
      expect(updated.zipCodeLabel, 'Updated');
      expect(updated.zipCodeHint, 'Updated');
      expect(updated.zipCodeHelper, 'Updated');
      expect(updated.villageLabel, 'Updated');
      expect(updated.villageHint, 'Updated');
      expect(updated.villageHelper, 'Updated');
      expect(updated.pickerTitle, 'Updated');
      expect(updated.confirmButton, 'Updated');
      expect(updated.cancelButton, 'Updated');
    });

    test('should copyWith null (no change) correctly', () {
      const original = ThaiAddressLabels(provinceLabel: 'Original');

      final same = original.copyWith();

      expect(same.provinceLabel, 'Original');
    });
  });
}
