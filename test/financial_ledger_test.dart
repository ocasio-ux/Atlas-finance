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
      transactionDate: DateTime(2026, 9, 15),
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
  test('payment from account to card reduces cash, card debt and frees limit', () {
    final account = const AtlasAccount(
      id: 'checking',
      name: 'Conta',
      type: AccountType.checking,
      initialBalance: 2000,
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
        AtlasTransaction(
          id: 'purchase',
          type: TransactionType.expense,
          amount: 700,
          description: 'Compra',
          createdAt: DateTime(2026, 9, 15),
          transactionDate: DateTime(2026, 9, 15),
          sourceType: TransactionSourceType.card,
          sourceId: 'card',
        ),
        AtlasTransaction(
          id: 'payment',
          type: TransactionType.transfer,
          amount: 700,
          description: 'Pagamento da fatura',
          createdAt: DateTime(2026, 9, 25),
          transactionDate: DateTime(2026, 9, 25),
          sourceType: TransactionSourceType.account,
          sourceId: 'checking',
          destinationType: TransactionSourceType.card,
          destinationId: 'card',
        ),
      ],
    );

    expect(ledger.accountBalance('checking'), 1300);
    expect(ledger.cardOutstandingDebt('card'), 0);
    expect(ledger.cardAvailableLimit('card'), 5000);
    expect(ledger.netAvailableBalance, 1300);
  });

  test('links a card payment to the exact invoice cycle', () {
    final card = const AtlasCard(
      id: 'card',
      name: 'Cartão',
      lastFourDigits: '1234',
      closingDay: 20,
      dueDay: 10,
      limit: 5000,
    );

    final invoice = FinancialLedger(
      accounts: const [],
      cards: [card],
      transactions: [
        AtlasTransaction(
          id: 'purchase',
          type: TransactionType.expense,
          amount: 700,
          description: 'Compra',
          createdAt: DateTime(2026, 9, 15),
          transactionDate: DateTime(2026, 9, 15),
          sourceType: TransactionSourceType.card,
          sourceId: 'card',
        ),
      ],
    ).currentCardInvoice('card', referenceDate: DateTime(2026, 9, 25));

    final ledger = FinancialLedger(
      accounts: const [],
      cards: [card],
      transactions: [
        AtlasTransaction(
          id: 'purchase',
          type: TransactionType.expense,
          amount: 700,
          description: 'Compra',
          createdAt: DateTime(2026, 9, 15),
          transactionDate: DateTime(2026, 9, 15),
          sourceType: TransactionSourceType.card,
          sourceId: 'card',
        ),
        AtlasTransaction(
          id: 'payment',
          type: TransactionType.transfer,
          amount: 700,
          description: 'Pagamento',
          createdAt: DateTime(2026, 9, 25),
          transactionDate: DateTime(2026, 9, 25),
          sourceType: TransactionSourceType.account,
          sourceId: 'account',
          destinationType: TransactionSourceType.card,
          destinationId: 'card',
          cardInvoiceEndDate: invoice.endDate,
        ),
      ],
    );

    expect(ledger.cardInvoice('card', referenceDate: DateTime(2026, 9, 25)), 0);
  });

  test('reports invoice status from payment and dates', () {
    final card = const AtlasCard(
      id: 'card',
      name: 'Cartão',
      lastFourDigits: '1234',
      closingDay: 20,
      dueDay: 10,
      limit: 5000,
    );

    final purchase = AtlasTransaction(
      id: 'purchase',
      type: TransactionType.expense,
      amount: 700,
      description: 'Compra',
      createdAt: DateTime(2026, 9, 15),
      transactionDate: DateTime(2026, 9, 15),
      sourceType: TransactionSourceType.card,
      sourceId: 'card',
    );

    final openInvoice = FinancialLedger(
      accounts: const [],
      cards: [card],
      transactions: [purchase],
    ).currentCardInvoice(
      'card',
      referenceDate: DateTime(2026, 9, 15),
    );
    expect(openInvoice.status(DateTime(2026, 9, 15)), CardInvoiceStatus.open);

    final closedInvoice = FinancialLedger(
      accounts: const [],
      cards: [card],
      transactions: [purchase],
    ).currentCardInvoice(
      'card',
      referenceDate: DateTime(2026, 9, 25),
    );
    expect(closedInvoice.status(DateTime(2026, 9, 25)), CardInvoiceStatus.closed);

    final overdueInvoice = FinancialLedger(
      accounts: const [],
      cards: [card],
      transactions: [purchase],
    ).currentCardInvoice(
      'card',
      referenceDate: DateTime(2026, 10, 11),
    );
    expect(overdueInvoice.status(DateTime(2026, 10, 11)), CardInvoiceStatus.overdue);

    final paidLedger = FinancialLedger(
      accounts: const [],
      cards: [card],
      transactions: [
        purchase,
        AtlasTransaction(
          id: 'payment',
          type: TransactionType.transfer,
          amount: 700,
          description: 'Pagamento',
          createdAt: DateTime(2026, 9, 25),
          transactionDate: DateTime(2026, 9, 25),
          sourceType: TransactionSourceType.account,
          sourceId: 'account',
          destinationType: TransactionSourceType.card,
          destinationId: 'card',
          cardInvoiceEndDate: closedInvoice.endDate,
        ),
      ],
    ).currentCardInvoice(
      'card',
      referenceDate: DateTime(2026, 9, 25),
    );
    expect(paidLedger.status(DateTime(2026, 9, 25)), CardInvoiceStatus.paid);
    expect(paidLedger.paidAmount, 700);
    expect(paidLedger.amount, 0);
  });

  test('calculates each installment in its corresponding billing cycle', () {
    final card = const AtlasCard(
      id: 'card',
      name: 'Cartão',
      lastFourDigits: '1234',
      closingDay: 20,
      dueDay: 10,
      limit: 5000,
    );

    final transactions = [
      AtlasTransaction(
        id: 'installment-1',
        type: TransactionType.expense,
        amount: 400,
        description: 'Compra parcelada',
        createdAt: DateTime(2026, 9, 15),
        transactionDate: DateTime(2026, 9, 15),
        sourceType: TransactionSourceType.card,
        sourceId: 'card',
        seriesId: 'series',
        installmentNumber: 1,
        installmentCount: 3,
      ),
      AtlasTransaction(
        id: 'installment-2',
        type: TransactionType.expense,
        amount: 400,
        description: 'Compra parcelada',
        createdAt: DateTime(2026, 9, 15),
        transactionDate: DateTime(2026, 10, 15),
        sourceType: TransactionSourceType.card,
        sourceId: 'card',
        seriesId: 'series',
        installmentNumber: 2,
        installmentCount: 3,
      ),
      AtlasTransaction(
        id: 'installment-3',
        type: TransactionType.expense,
        amount: 400,
        description: 'Compra parcelada',
        createdAt: DateTime(2026, 9, 15),
        transactionDate: DateTime(2026, 11, 15),
        sourceType: TransactionSourceType.card,
        sourceId: 'card',
        seriesId: 'series',
        installmentNumber: 3,
        installmentCount: 3,
      ),
    ];

    final ledger = FinancialLedger(
      accounts: const [],
      cards: [card],
      transactions: transactions,
    );

    expect(
      ledger.cardInvoice('card', referenceDate: DateTime(2026, 9, 25)),
      400,
    );
    expect(
      ledger.cardInvoice('card', referenceDate: DateTime(2026, 10, 25)),
      400,
    );
    expect(
      ledger.cardInvoice('card', referenceDate: DateTime(2026, 11, 25)),
      400,
    );
    expect(ledger.cardOutstandingDebt('card'), 1200);
  });

}
