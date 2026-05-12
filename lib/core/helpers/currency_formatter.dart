class CurrencyFormatter {
  CurrencyFormatter._();

  static String formatRupiah(
    num? amount, {
    String symbol = 'Rp',
    int decimalDigits = 0,
  }) {
    if (amount == null) {
      return '$symbol 0';
    }

    final isNegative = amount < 0;
    final absoluteAmount = amount.abs();

    // Convert to int when decimalDigits is 0 to avoid decimal portion issues
    final valueToFormat = decimalDigits > 0
        ? absoluteAmount
        : absoluteAmount.toInt();

    final fixedValue = valueToFormat.toStringAsFixed(decimalDigits);
    final parts = fixedValue.split('.');
    final whole = parts.first;
    final decimal = parts.length > 1 ? parts.last : '';
    final buffer = StringBuffer();

    for (var index = 0; index < whole.length; index++) {
      final reversedIndex = whole.length - index;
      buffer.write(whole[index]);
      if (reversedIndex > 1 && reversedIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    final formattedNumber = decimalDigits > 0
        ? '${buffer.toString()},$decimal'
        : buffer.toString();

    return '${isNegative ? '-' : ''}$symbol$formattedNumber';
  }

  static String formatRupiahFromString(
    String? rawAmount, {
    String emptyValue = 'Biaya belum diatur',
    String symbol = 'Rp',
    int decimalDigits = 0,
  }) {
    if (rawAmount == null || rawAmount.trim().isEmpty) {
      return emptyValue;
    }

    final sanitized = rawAmount
        .replaceAll(RegExp(r'[^0-9,.]'), '')
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'\.\d+$'), '');
    final amount = num.tryParse(sanitized);

    if (amount == null) {
      return emptyValue;
    }

    return formatRupiah(amount, symbol: symbol, decimalDigits: decimalDigits);
  }
}
