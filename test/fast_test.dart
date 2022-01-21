import 'package:flutter_test/flutter_test.dart';

import 'package:fast/fast.dart';

void main() {
  test('Check platform', () {
    expect(Platform.isLinux, true);
  });

  test('Check dpi', () {
    expect(Screen.dpi, 96);
  });
}
