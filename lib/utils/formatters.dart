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
  final cleaned =
      input.trim().replaceAll(RegExp(r'[^0-9,\.]'), '').replaceAll(',', '.');
  if (cleaned.isEmpty) return null;
  return double.tryParse(cleaned);
}
