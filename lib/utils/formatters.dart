String formatMoneyBRL(num value) {
  final negative = value < 0;
  final abs = value.abs();
  final fixed = abs.toStringAsFixed(2);
  final parts = fixed.split('.');
  final inteiro = parts[0];
  final centavos = parts.length > 1 ? parts[1] : '00';
  final buffer = StringBuffer();
  for (var i = 0; i < inteiro.length; i++) {
    final indexFromEnd = inteiro.length - i;
    buffer.write(inteiro[i]);
    if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
      buffer.write('.');
    }
  }
  final prefix = negative ? '-R\$ ' : 'R\$ ';
  return '$prefix${buffer.toString()},$centavos';
}

String formatDateBR(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}';
}

double? parseMoneyInput(String input) {
  final value = input.trim().replaceAll(RegExp(r'[^0-9,\.]'), '');
  if (value.isEmpty) return null;

  final lastComma = value.lastIndexOf(',');
  final lastDot = value.lastIndexOf('.');
  final decimalSeparatorIndex = lastComma > lastDot ? lastComma : lastDot;
  final separators = RegExp(r'[,\.]').allMatches(value).length;

  if (decimalSeparatorIndex == -1) {
    return double.tryParse(value);
  }

  if (separators == 1 && value.length - decimalSeparatorIndex - 1 == 3) {
    return double.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  final integerPart = value
      .substring(0, decimalSeparatorIndex)
      .replaceAll(RegExp(r'[^0-9]'), '');
  final decimalPart = value
      .substring(decimalSeparatorIndex + 1)
      .replaceAll(RegExp(r'[^0-9]'), '');

  if (integerPart.isEmpty && decimalPart.isEmpty) return null;
  final normalizedInteger = integerPart.isEmpty ? '0' : integerPart;
  final normalized = decimalPart.isEmpty
      ? normalizedInteger
      : '$normalizedInteger.$decimalPart';
  return double.tryParse(normalized);
}
