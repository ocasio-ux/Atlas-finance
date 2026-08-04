/// Centralized Brazilian Real formatting for Atlas.
///
/// Keeps money presentation consistent without adding another dependency.
abstract final class CurrencyFormatter {
  static String brl(double value) {
    final negative = value < 0;
    final cents = (value.abs() * 100).round();
    final whole = cents ~/ 100;
    final decimal = (cents % 100).toString().padLeft(2, '0');
    final digits = whole.toString();
    final groups = <String>[];

    for (var end = digits.length; end > 0; end -= 3) {
      final start = (end - 3).clamp(0, digits.length);
      groups.insert(0, digits.substring(start, end));
    }

    final sign = negative ? '- ' : '';
    return '$sign${r'R$'} ${groups.join('.')},$decimal';
  }

  static double? parseBrl(String input) {
    var raw = input.trim().replaceAll(r'R$', '').replaceAll(' ', '');
    if (raw.isEmpty) return null;

    if (raw.contains(',')) {
      raw = raw.replaceAll('.', '').replaceAll(',', '.');
    }

    return double.tryParse(raw);
  }
}
