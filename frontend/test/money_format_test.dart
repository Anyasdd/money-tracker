import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/utils/money_format.dart';

void main() {
  test('Money formatting works', () {
    expect(formatSom('250.5'), '250,50 сом');
    expect(formatSom('0'), '0,00 сом');
    expect(formatSom('-10.25'), '-10,25 сом');
  });

  test('Money is converted to tyiyn correctly', () {
    expect(somToTyiyn('250.50'), 25050);
    expect(somToTyiyn('100.25'), 10025);
    expect(formatTyiyn(35075), '350,75 сом');
  });
}
