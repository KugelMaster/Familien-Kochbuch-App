import 'package:intl/intl.dart';

class Format {
  static String number(double? number, {String defaultReturn = "N/A"}) {
    return number
            ?.toStringAsFixed(1)
            .replaceAll(",", ".")
            .replaceAll(".0", "") ??
        defaultReturn;
  }

  static String date(DateTime? date) {
    if (date == null) return "";

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 7) {
      if (difference.inDays == 0) {
        if (difference.inHours == 0 && difference.inMinutes <= 3) return "Gerade eben";
        return "Vor ${difference.inHours} Std.";
      }
      if (difference.inDays == 1) return "Gestern";
      return "Vor ${difference.inDays} Tagen";
    }

    // Wenn älter als 7 Tage -> Statisch
    return DateFormat.yMMMEd("de_DE").format(date);
  }
}
