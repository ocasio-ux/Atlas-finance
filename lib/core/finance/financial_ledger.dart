import '../accounts/account_model.dart';
import '../cards/card_model.dart';
import '../transactions/transaction_model.dart';
import 'card_invoice.dart';

/// Deterministic financial calculations shared by Atlas screens and engines.
///
/// Accounts represent available money. Cards represent credit usage and are
/// therefore kept separate from the consolidated cash balance.
class FinancialLedger {
  const FinancialLedger({
    required this.accounts,
    required this.cards,
    required this.transactions,
  });

  final Iterable<AtlasAccount> accounts;
  final Iterable<AtlasCard> cards;
  final Iterable<AtlasTransaction> transactions;

  double accountBalance(String accountId) {
    final account = _findAccount(accountId);
    if (account == null) return 0;

    var balance = account.initialBalance;
    for (final transaction in transactions) {
      final affectsAsSource =
          transaction.sourceType == TransactionSourceType.account &&
          transaction.sourceId == accountId;
      final affectsAsDestination =
          transaction.destinationType == TransactionSourceType.account &&
          transaction.destinationId == accountId;

      if (!affectsAsSource && !affectsAsDestination) continue;

      switch (transaction.type) {
        case TransactionType.income:
          balance += transaction.amount;
        case TransactionType.expense:
          balance -= transaction.amount;
        case TransactionType.transfer:
          if (affectsAsDestination) {
            balance += transaction.amount;
          } else if (affectsAsSource) {
            balance -= transaction.amount;
          }
          break;
      }
    }
    return balance;
  }

  double get consolidatedBalance => accounts.fold<double>(
        0,
        (sum, account) => sum + accountBalance(account.id),
      );

  CardInvoice currentCardInvoice(String cardId, {DateTime? referenceDate}) {
    final card = _findCard(cardId);
    if (card == null) {
      final now = referenceDate ?? DateTime.now();
      return CardInvoice(
        cardId: cardId,
        startDate: now,
        endDate: now,
        dueDate: now,
        billedAmount: 0,
        paidAmount: 0,
      );
    }

    final reference = referenceDate ?? DateTime.now();
    final cycleEnd = _closingDateOnOrBefore(
      reference.year,
      reference.month,
      card.closingDay,
      reference,
    );
    final previous = _shiftMonth(cycleEnd, -1);
    final cycleStart = _date(
      previous.year,
      previous.month,
      card.closingDay,
    ).add(const Duration(days: 1));
    final dueDate = _dueDate(cycleEnd, card.dueDay, card.closingDay);

    return _invoiceForPeriod(
      card,
      cycleStart,
      cycleEnd,
      dueDate,
    );
  }

  List<CardInvoice> cardInvoiceHistory(
    String cardId, {
    DateTime? referenceDate,
    int monthsBack = 5,
  }) {
    final card = _findCard(cardId);
    if (card == null) return const [];

    final reference = referenceDate ?? DateTime.now();
    final currentEnd = _closingDateOnOrBefore(
      reference.year,
      reference.month,
      card.closingDay,
      reference,
    );

    return List.generate(monthsBack + 1, (index) {
      final end = _shiftMonth(currentEnd, -index);
      return _invoiceForClosingDate(card, end);
    });
  }

  CardInvoice _invoiceForClosingDate(AtlasCard card, DateTime cycleEnd) {
    final previous = _shiftMonth(cycleEnd, -1);
    final cycleStart = _date(
      previous.year,
      previous.month,
      card.closingDay,
    ).add(const Duration(days: 1));
    final dueDate = _dueDate(cycleEnd, card.dueDay, card.closingDay);

    return _invoiceForPeriod(
      card,
      cycleStart,
      cycleEnd,
      dueDate,
    );
  }

  CardInvoice _invoiceForPeriod(
    AtlasCard card,
    DateTime cycleStart,
    DateTime cycleEnd,
    DateTime dueDate,
  ) {
    var billedAmount = 0.0;
    var paidAmount = 0.0;

    for (final transaction in transactions) {
      final cardMovement =
          transaction.sourceType == TransactionSourceType.card &&
          transaction.sourceId == card.id;
      final invoicePayment =
          transaction.type == TransactionType.transfer &&
          transaction.destinationType == TransactionSourceType.card &&
          transaction.destinationId == card.id &&
          transaction.cardInvoiceEndDate != null &&
          _sameDate(transaction.cardInvoiceEndDate!, cycleEnd);

      if (cardMovement &&
          !transaction.transactionDate.isBefore(cycleStart) &&
          !transaction.transactionDate.isAfter(cycleEnd)) {
        if (transaction.type == TransactionType.expense) {
          billedAmount += transaction.amount;
        } else if (transaction.type == TransactionType.income) {
          billedAmount -= transaction.amount;
        }
      }

      if (invoicePayment) {
        paidAmount += transaction.amount;
      }
    }

    billedAmount = billedAmount < 0 ? 0 : billedAmount;
    paidAmount = paidAmount.clamp(0, billedAmount).toDouble();

    return CardInvoice(
      cardId: card.id,
      startDate: cycleStart,
      endDate: cycleEnd,
      dueDate: dueDate,
      billedAmount: billedAmount,
      paidAmount: paidAmount,
    );
  }

  double cardInvoice(String cardId, {DateTime? referenceDate}) =>
      currentCardInvoice(cardId, referenceDate: referenceDate).amount;

  double cardOutstandingDebt(String cardId) {
    if (_findCard(cardId) == null) return 0;

    var debt = 0.0;
    for (final transaction in transactions) {
      final cardMovement =
          transaction.sourceType == TransactionSourceType.card &&
          transaction.sourceId == cardId;
      final cardPayment =
          transaction.type == TransactionType.transfer &&
          transaction.destinationType == TransactionSourceType.card &&
          transaction.destinationId == cardId;

      if (cardMovement) {
        if (transaction.type == TransactionType.expense) {
          debt += transaction.amount;
        } else if (transaction.type == TransactionType.income) {
          debt -= transaction.amount;
        }
      }

      if (cardPayment) {
        debt -= transaction.amount;
      }
    }

    return debt < 0 ? 0 : debt;
  }

  double? cardAvailableLimit(String cardId) {
    final card = _findCard(cardId);
    if (card?.limit == null) return null;

    return (card!.limit! - cardOutstandingDebt(cardId))
        .clamp(0, card.limit!)
        .toDouble();
  }

  double get totalCardDebt => cards.fold<double>(
        0,
        (sum, card) => sum + cardOutstandingDebt(card.id),
      );

  double get netAvailableBalance => consolidatedBalance - totalCardDebt;

  AtlasAccount? _findAccount(String id) {
    for (final account in accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  AtlasCard? _findCard(String id) {
    for (final card in cards) {
      if (card.id == id) return card;
    }
    return null;
  }

  static DateTime _closingDateOnOrBefore(
    int year,
    int month,
    int closingDay,
    DateTime reference,
  ) {
    final candidate = _date(year, month, closingDay);
    if (!candidate.isAfter(reference)) return candidate;

    final previousMonth = month == 1 ? 12 : month - 1;
    final previousYear = month == 1 ? year - 1 : year;
    return _date(previousYear, previousMonth, closingDay);
  }

  static DateTime _dueDate(
    DateTime closingDate,
    int dueDay,
    int closingDay,
  ) {
    final dueMonth = dueDay > closingDay
        ? closingDate.month
        : closingDate.month == 12
        ? 1
        : closingDate.month + 1;
    final dueYear = dueDay > closingDay
        ? closingDate.year
        : closingDate.month == 12
        ? closingDate.year + 1
        : closingDate.year;

    return _date(dueYear, dueMonth, dueDay);
  }

  static DateTime _shiftMonth(DateTime date, int months) {
    final target = DateTime(date.year, date.month + months, 1);
    return _date(target.year, target.month, date.day);
  }

  static bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime _date(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day.clamp(1, lastDay));
  }
}
