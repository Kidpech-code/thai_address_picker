import 'package:flutter_test/flutter_test.dart';
import 'package:thai_address_picker/src/repository/thai_address_repository.dart';

void main() {
  test('parseJsonInIsolate throws on unknown type', () {
    final params = JsonParseParams('[]', 'unknown_type');
    expect(() => parseJsonInIsolate(params), throwsException);
  });
}
