import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/thai_address_picker.dart';

void main() {
  group('Generated Models Coverage', () {
    test('Geography toJson', () {
      const g = Geography(id: 1, name: 'Geo');
      expect(g.toJson(), {'id': 1, 'name': 'Geo'});
    });

    // Although other models use manual fromJson and Freezed,
    // Freezed usually generates toJson which might be used or registered.
    // If they have @freezed, they have toJson if part of the mixin.
    // Let's check access to toJson on other models.

    test('Province toJson', () {
      // Freeze usually adds toJson if json_serializable is involved or implied.
      // The code uses `Province.fromJson` manual factory?
      // Let's check province.dart
    });
  });
}
