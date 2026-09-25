enum CardInvoiceStatus {
  open,
  closed,
  overdue,
  paid,
}

class CardInvoice {
  const CardInvoice({
    required this.cardId,
    required this.startDate,
    required this.endDate,
    required this.dueDate,
    required this.billedAmount,
    required this.paidAmount,
  });

  final String cardId;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime dueDate;
  final double billedAmount;
  final double paidAmount;

  double get amount =>
      (billedAmount - paidAmount).clamp(0, double.infinity).toDouble();

  CardInvoiceStatus status(DateTime referenceDate) {
    if (billedAmount > 0 && amount <= 0) {
      return CardInvoiceStatus.paid;
    }
    if (referenceDate.isAfter(dueDate)) {
      return CardInvoiceStatus.overdue;
    }
    if (referenceDate.isAfter(endDate)) {
      return CardInvoiceStatus.closed;
    }
    return CardInvoiceStatus.open;
  }
}
