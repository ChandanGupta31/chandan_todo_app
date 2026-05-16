class TaskDateUtils {
  /// Calculates the next due date based on the recurrence configuration
  static DateTime calculateNextDueDate(DateTime currentDueDate, String recurrenceType) {
    switch (recurrenceType.toLowerCase()) {
      case 'daily':
        return currentDueDate.add(const Duration(days: 1));
      case 'alternate':
        return currentDueDate.add(const Duration(days: 2));
      case 'weekly':
        return currentDueDate.add(const Duration(days: 7));
      case 'monthly':
        // Safely add 1 month handling different month lengths
        return DateTime(
          currentDueDate.year,
          currentDueDate.month + 1,
          currentDueDate.day,
        );
      default:
        return currentDueDate;
    }
  }
}