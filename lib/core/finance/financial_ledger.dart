import '../accounts/account_model.dart';
import '../cards/card_model.dart';
import '../transactions/transaction_model.dart';

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
      if (transaction.sourceType != TransactionSourceType.account ||
          transaction.sourceId != accountId) {
        continue;
      }

      switch (transaction.type) {
        case TransactionType.income:
          balance += transaction.amount;
        case TransactionType.expense:
          balance -= transaction.amount;
        case TransactionType.transfer:
          // The current transaction model has no destination yet, so an
          // existing transfer cannot be applied to an account reliably.
          break;
      }
    }
    return balance;
  }

  double get consolidatedBalance => accounts.fold<double>(
        0,
        (sum, account) => sum + accountBalance(account.id),
      );

  double cardInvoice(String cardId) {
    if (_findCard(cardId) == null) return 0;

    var invoice = 0.0;
    for (final transaction in transactions) {
      if (transaction.sourceType != TransactionSourceType.card ||
          transaction.sourceId != cardId) {
        continue;
      }

      switch (transaction.type) {
        case TransactionType.expense:
          invoice += transaction.amount;
        case TransactionType.income:
          invoice -= transaction.amount;
        case TransactionType.transfer:
          break;
      }
    }

    return invoice < 0 ? 0 : invoice;
  }

  double? cardAvailableLimit(String cardId) {
    final card = _findCard(cardId);
    if (card?.limit == null) return null;
    return (card!.limit! - cardInvoice(cardId))
        .clamp(0, card.limit!)
        .toDouble();
  }

  double get totalCardDebt => cards.fold<double>(
        0,
        (sum, card) => sum + cardInvoice(card.id),
      );

  /// Cash available after outstanding card debt.
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
}
