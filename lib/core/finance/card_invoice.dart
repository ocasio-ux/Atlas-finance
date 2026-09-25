class CardInvoice {
  const CardInvoice({
    required this.cardId,
    required this.startDate,
    required this.endDate,
    required this.dueDate,
    required this.amount,
  });

  final String cardId;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime dueDate;
  final double amount;
}
