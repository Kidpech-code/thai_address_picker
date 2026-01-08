/// Customizable labels for Thai Address Picker widgets
///
/// Provides full localization control for all UI text in the package.
/// If labels are not provided, the package will use default Thai or English labels
/// based on the [useThai] parameter in each widget.
///
/// Usage:
/// ```dart
/// ThaiAddressForm(
///   labels: ThaiAddressLabels(
///     provinceLabel: 'Custom Province Label',
///     districtLabel: 'Custom District Label',
///   ),
/// )
/// ```
class ThaiAddressLabels {
  // Province field labels
  final String? provinceLabel;

  // District field labels
  final String? districtLabel;

  // Sub-district field labels
  final String? subDistrictLabel;

  // Zip code field labels
  final String? zipCodeLabel;
  final String? zipCodeHint;
  final String? zipCodeHelper;

  // Village field labels
  final String? villageLabel;
  final String? villageHint;
  final String? villageHelper;

  // Picker dialog/bottom sheet labels
  final String? pickerTitle;
  final String? confirmButton;
  final String? cancelButton;

  const ThaiAddressLabels({
    this.provinceLabel,
    this.districtLabel,
    this.subDistrictLabel,
    this.zipCodeLabel,
    this.zipCodeHint,
    this.zipCodeHelper,
    this.villageLabel,
    this.villageHint,
    this.villageHelper,
    this.pickerTitle,
    this.confirmButton,
    this.cancelButton,
  });

  /// Creates a copy with some fields replaced
  ThaiAddressLabels copyWith({
    String? provinceLabel,
    String? districtLabel,
    String? subDistrictLabel,
    String? zipCodeLabel,
    String? zipCodeHint,
    String? zipCodeHelper,
    String? villageLabel,
    String? villageHint,
    String? villageHelper,
    String? pickerTitle,
    String? confirmButton,
    String? cancelButton,
  }) {
    return ThaiAddressLabels(
      provinceLabel: provinceLabel ?? this.provinceLabel,
      districtLabel: districtLabel ?? this.districtLabel,
      subDistrictLabel: subDistrictLabel ?? this.subDistrictLabel,
      zipCodeLabel: zipCodeLabel ?? this.zipCodeLabel,
      zipCodeHint: zipCodeHint ?? this.zipCodeHint,
      zipCodeHelper: zipCodeHelper ?? this.zipCodeHelper,
      villageLabel: villageLabel ?? this.villageLabel,
      villageHint: villageHint ?? this.villageHint,
      villageHelper: villageHelper ?? this.villageHelper,
      pickerTitle: pickerTitle ?? this.pickerTitle,
      confirmButton: confirmButton ?? this.confirmButton,
      cancelButton: cancelButton ?? this.cancelButton,
    );
  }

  /// Default Thai labels
  static const ThaiAddressLabels thai = ThaiAddressLabels(
    provinceLabel: 'จังหวัด',
    districtLabel: 'อำเภอ/เขต',
    subDistrictLabel: 'ตำบล/แขวง',
    zipCodeLabel: 'รหัสไปรษณีย์',
    zipCodeHint: 'กรอก 5 หลัก',
    zipCodeHelper: 'ระบบจะแนะนำที่อยู่อัตโนมัติ',
    villageLabel: 'หมู่บ้าน',
    villageHint: 'ค้นหาชื่อหมู่บ้าน',
    villageHelper: 'ระบบจะแนะนำหมู่บ้านอัตโนมัติ',
    pickerTitle: 'เลือกที่อยู่',
    confirmButton: 'ยืนยัน',
    cancelButton: 'ยกเลิก',
  );

  /// Default English labels
  static const ThaiAddressLabels english = ThaiAddressLabels(
    provinceLabel: 'Province',
    districtLabel: 'District',
    subDistrictLabel: 'Sub-district',
    zipCodeLabel: 'Zip Code',
    zipCodeHint: 'Enter 5 digits',
    zipCodeHelper: 'Auto-suggestions enabled',
    villageLabel: 'Village',
    villageHint: 'Search village name',
    villageHelper: 'Auto-suggestions enabled',
    pickerTitle: 'Select Address',
    confirmButton: 'Confirm',
    cancelButton: 'Cancel',
  );

  /// Get label with fallback to default Thai or English
  String getProvinceLabel(bool useThai) =>
      provinceLabel ?? (useThai ? thai.provinceLabel! : english.provinceLabel!);

  String getDistrictLabel(bool useThai) =>
      districtLabel ?? (useThai ? thai.districtLabel! : english.districtLabel!);

  String getSubDistrictLabel(bool useThai) =>
      subDistrictLabel ??
      (useThai ? thai.subDistrictLabel! : english.subDistrictLabel!);

  String getZipCodeLabel(bool useThai) =>
      zipCodeLabel ?? (useThai ? thai.zipCodeLabel! : english.zipCodeLabel!);

  String getZipCodeHint(bool useThai) =>
      zipCodeHint ?? (useThai ? thai.zipCodeHint! : english.zipCodeHint!);

  String getZipCodeHelper(bool useThai) =>
      zipCodeHelper ?? (useThai ? thai.zipCodeHelper! : english.zipCodeHelper!);

  String getVillageLabel(bool useThai) =>
      villageLabel ?? (useThai ? thai.villageLabel! : english.villageLabel!);

  String getVillageHint(bool useThai) =>
      villageHint ?? (useThai ? thai.villageHint! : english.villageHint!);

  String getVillageHelper(bool useThai) =>
      villageHelper ?? (useThai ? thai.villageHelper! : english.villageHelper!);

  String getPickerTitle(bool useThai) =>
      pickerTitle ?? (useThai ? thai.pickerTitle! : english.pickerTitle!);

  String getConfirmButton(bool useThai) =>
      confirmButton ?? (useThai ? thai.confirmButton! : english.confirmButton!);

  String getCancelButton(bool useThai) =>
      cancelButton ?? (useThai ? thai.cancelButton! : english.cancelButton!);
}
