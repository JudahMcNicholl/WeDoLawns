extension DoubleFormatter on double {
  /// Formats the double to one decimal place if necessary.
  /// Whole numbers are returned without a decimal point.
  String formatWithOptionalDecimal({int precision = 1}) {
    return this % 1 == 0 ? toStringAsFixed(0) : toStringAsFixed(precision);
  }
}
