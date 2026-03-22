class DeadlineService {
  static final DateTime _anchorDeadline = DateTime(2026, 3, 27);

  static const int _cycleDays = 14; // every 2 weeks

  static DateTime getNextDeadline() {
    final now = DateTime.now();

    if (!now.isAfter(_anchorDeadline)) {
      return _anchorDeadline;
    }

    final daysSinceAnchor = now.difference(_anchorDeadline).inDays;
    final cyclesPassed = (daysSinceAnchor / _cycleDays).ceil();
    final nextDeadline =
        _anchorDeadline.add(Duration(days: cyclesPassed * _cycleDays));

    return nextDeadline;
  }

  static int daysUntilDeadline() {
    final deadline = getNextDeadline();
    return deadline.difference(DateTime.now()).inDays;
  }

  static String formattedDeadline() {
    final deadline = getNextDeadline();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[deadline.month - 1]} ${deadline.day}, ${deadline.year}';
  }
}