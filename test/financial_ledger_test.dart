import 'package:flutter_test/flutter_test.dart';

import 'package:atlas_finance/features/accounts/account_model.dart';
import 'package:atlas_finance/features/cards/card_model.dart';
import 'package:atlas_finance/core/finance/financial_ledger.dart';
import 'package:atlas_finance/features/transactions/transaction_model.dart';

void main() {
  AtlasTransaction transaction({
    required String id,
    required TransactionType type,
    required double amount,
    TransactionSourceType? sourceType,
    String? sourceId,
  }) {
    return AtlasTransaction(
      id: id,
      type: type,
      amount: amount,
      description: id,
      createdAt: DateTime(2026, 9, 25),
      sourceType: sourceType,
      sourceId: sourceId,
    );
  }

  test('calculates each account from opening balance and linked transactions', () {
    final account = const AtlasAccount(
      id: 'checking',
      name: 'Conta',
      type: AccountType.checking,
      initialBalance: 1000,
    );

    final ledger = FinancialLedger(
      accounts: [account],
      cards: const [],
      transactions: [
        transaction(
          id: 'salary',
          type: TransactionType.income,
          amount: 2000,
          sourceType: TransactionSourceType.account,
          sourceId: 'checking',
        ),
        transaction(
          id: 'rent',
          type: TransactionType.expense,
          amount: 300,
          sourceType: TransactionSourceType.account,
          sourceId: 'checking',
        ),
      ],
    );

    expect(ledger.accountBalance('checking'), 2700);
    expect(ledger.consolidatedBalance, 2700);
  });

  test('calculates card invoice and available limit independently from cash', () {
    final account = const AtlasAccount(
      id: 'checking',
      name: 'Conta',
      type: AccountType.checking,
      initialBalance: 5000,
    );
    final card = const AtlasCard(
      id: 'card',
      name: 'Cartão',
      lastFourDigits: '1234',
      closingDay: 20,
      dueDay: 10,
      limit: 5000,
    );

    final ledger = FinancialLedger(
      accounts: [account],
      cards: [card],
      transactions: [
        transaction(
          id: 'purchase',
          type: TransactionType.expense,
          amount: 700,
          sourceType: TransactionSourceType.card,
          sourceId: 'card',
        ),
      ],
    );

    expect(ledger.consolidatedBalance, 5000);
    expect(ledger.cardInvoice('card'), 700);
    expect(ledger.cardAvailableLimit('card'), 4300);
    expect(ledger.netAvailableBalance, 4300);
  });

  test('moves value between two accounts without changing consolidated balance', () {
    final source = const AtlasAccount(
      id: 'source',
      name: 'Origem',
      type: AccountType.checking,
      initialBalance: 1000,
    );
    final destination = const AtlasAccount(
      id: 'destination',
      name: 'Destino',
      type: AccountType.savings,
      initialBalance: 200,
    );

    final ledger = FinancialLedger(
      accounts: [source, destination],
      cards: const [],
      transactions: [
        AtlasTransaction(
          id: 'transfer',
          type: TransactionType.transfer,
          amount: 500,
          description: 'Transferência',
          createdAt: DateTime(2026, 9, 25),
          sourceType: TransactionSourceType.account,
          sourceId: 'source',
          destinationType: TransactionSourceType.account,
          destinationId: 'destination',
        ),
      ],
    );

    expect(ledger.accountBalance('source'), 500);
    expect(ledger.accountBalance('destination'), 700);
    expect(ledger.consolidatedBalance, 1200);
  });
}
