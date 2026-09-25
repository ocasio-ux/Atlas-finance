import '../transactions/transaction_model.dart';

class TransactionRecurrenceEngine {
  const TransactionRecurrenceEngine();

  Iterable<AtlasTransaction> occurrencesBetween(
    AtlasTransaction template, {
    required DateTime start,
    required DateTime end,
  }) sync* {
    if (template.repeat == TransactionRepeat.none ||
        end.isBefore(start)) {
      return;
    }

    var occurrenceDate = _addMonths(template.transactionDate, 1);
    final recurrenceEnd = template.repeatEndDate;
    while (!occurrenceDate.isAfter(end) &&
        (recurrenceEnd == null || !occurrenceDate.isAfter(recurrenceEnd))) {
      if (!occurrenceDate.isBefore(start)) {
        yield AtlasTransaction(
          id: '${template.id}_recurrence_${occurrenceDate.year}_${occurrenceDate.month}',
          type: template.type,
          amount: template.amount,
          description: template.description,
          createdAt: template.createdAt,
          transactionDate: occurrenceDate,
          category: template.category,
          sourceType: template.sourceType,
          sourceId: template.sourceId,
          destinationType: template.destinationType,
          destinationId: template.destinationId,
          repeat: TransactionRepeat.none,
          repeatEndDate: null,
          seriesId: template.seriesId ?? template.id,
          cardInvoiceEndDate: null,
        );
      }
      occurrenceDate = _addMonths(occurrenceDate, 1);
    }
  }

  DateTime _addMonths(DateTime date, int months) {
    final targetMonth = date.month - 1 + months;
    final year = date.year + targetMonth ~/ 12;
    final month = targetMonth % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(
      year,
      month,
      date.day.clamp(1, lastDay),
      date.hour,
      date.minute,
      date.second,
    );
  }
}
