import 'package:intl/intl.dart';

class Format {
  static String number(double? number, {String defaultReturn = "N/A"}) {
    return number
            ?.toStringAsFixed(1)
            .replaceAll(",", ".")
            .replaceAll(".0", "") ??
        defaultReturn;
  }

  static double? parseString(String value) {
    return double.tryParse(value.replaceAll(",", "."));
  }

  /// Formats the given DateTime into a relative value.
  /// If it is older than 7 days, the date is returned in German format.
  static String date(DateTime? date) {
    if (date == null) return "";

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 7) {
      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes <= 1) {
            return "Gerade eben";
          }
          return "Vor ${difference.inMinutes} Min.";
        }
        return "Vor ${difference.inHours} Std.";
      }
      if (difference.inDays == 1) return "Gestern";
      return "Vor ${difference.inDays} Tagen";
    }

    return DateFormat.yMMMEd("de_DE").format(date);
  }

  static String dateWithUpdated(DateTime? createdAt, DateTime? updatedAt) {
    if (createdAt == null || updatedAt == null) return "";

    final createdAtStr = Format.date(createdAt);

    if (updatedAt.difference(createdAt).inSeconds <= 3) return createdAtStr;

    return "$createdAt (bearbeitet)";
  }

  static String time(int? time) {
    if (time == null) {
      return "N/A";
    }

    final int hours = time ~/ 60;
    final int minutes = time % 60;

    return "${hours == 0 ? "" : "$hours Std. "}$minutes Min";
  }
}
