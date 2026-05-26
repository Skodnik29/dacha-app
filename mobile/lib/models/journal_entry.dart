/// Запись в журнале наблюдений.
class JournalEntry {
  final String date;
  final String text;
  final String zone;
  final bool hasPhoto;

  const JournalEntry({
    required this.date,
    required this.text,
    required this.zone,
    this.hasPhoto = false,
  });
}
