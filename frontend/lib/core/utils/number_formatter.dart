class Utils {
  static String formatNumber(double? number, {String defaultReturn = "N/A"}) {
    return number
            ?.toStringAsFixed(1)
            .replaceAll(",", ".")
            .replaceAll(".0", "") ??
        defaultReturn;
  }
}
