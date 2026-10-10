import '../../features/accounts/account_model.dart';
import '../../features/transactions/transaction_model.dart';

class SandboxOpenFinanceConnection {
  const SandboxOpenFinanceConnection({
    required this.account,
    required this.transactions,
  });

  final AtlasAccount account;
  final List<AtlasTransaction> transactions;
}

/// Dados fictícios para validar o fluxo de Open Finance sem contratar um provedor.
class SandboxOpenFinanceGateway {
  const SandboxOpenFinanceGateway();

  SandboxOpenFinanceConnection connect() {
    const accountId = 'sandbox-atlas-account';
    final now = DateTime.now();
    return SandboxOpenFinanceConnection(
      account: const AtlasAccount(
        id: accountId,
        name: 'Banco Atlas (Sandbox)',
        type: AccountType.checking,
        initialBalance: 1250,
      ),
      transactions: [
        AtlasTransaction(
          id: 'sandbox-salary',
          type: TransactionType.income,
          amount: 3000,
          description: 'Salário de teste',
          category: TransactionCategory.salary,
          createdAt: now.subtract(const Duration(days: 5)),
          sourceType: TransactionSourceType.account,
          sourceId: accountId,
        ),
        AtlasTransaction(
          id: 'sandbox-market',
          type: TransactionType.expense,
          amount: 1325,
          description: 'Supermercado de teste',
          category: TransactionCategory.food,
          createdAt: now.subtract(const Duration(days: 2)),
          sourceType: TransactionSourceType.account,
          sourceId: accountId,
        ),
      ],
    );
  }
}
