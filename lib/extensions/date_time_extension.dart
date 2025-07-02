extension DateTimeExtension on DateTime {
  String get formattedDate => '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-${year}';
  bool isSameDay(DateTime other) => year == other.year && month == other.month && day == other.day;
}