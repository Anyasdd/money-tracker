import 'package:intl/intl.dart';

final _numberFormatter = NumberFormat.decimalPattern('ru_RU');

// Переводим сумму в тыйыны для точных вычислений.
int somToTyiyn(String amount) {
  final value = amount.trim().replaceAll(',', '.');

  final match = RegExp(r'^(-?)(\d+)(?:\.(\d{1,2}))?$').firstMatch(value);

  if (match == null) {
    throw FormatException('Некорректная сумма: $amount');
  }

  final whole = int.parse(match.group(2)!);
  final fractional = (match.group(3) ?? '').padRight(2, '0');

  final result = whole * 100 + int.parse(fractional);

  return match.group(1) == '-' ? -result : result;
}

// Форматируем целое количество тыйынов.
String formatTyiyn(int value) {
  final sign = value < 0 ? '-' : '';
  final absolute = value.abs();

  final som = absolute ~/ 100;
  final tyiyn = (absolute % 100).toString().padLeft(2, '0');

  final grouped = _numberFormatter.format(som);

  return '$sign$grouped,$tyiyn сом';
}

// Форматируем строку, полученную от FastAPI.
String formatSom(String value) {
  return formatTyiyn(somToTyiyn(value));
}
