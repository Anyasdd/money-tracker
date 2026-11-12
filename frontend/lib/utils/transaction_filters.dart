import '../models/transaction.dart';

// Виды фильтров
enum TransactionFilter { all, income, expense }

// Поиск и фильтрация транзакций
List<Transaction> filterTransactions(
  List<Transaction> transactions, {
  String query = '',
  TransactionFilter filter = TransactionFilter.all,
}) {
  final search = query.trim().toLowerCase();

  final result = transactions.where((transaction) {
    // Фильтр по типу
    if (filter == TransactionFilter.income && !transaction.isIncome) {
      return false;
    }

    if (filter == TransactionFilter.expense && transaction.isIncome) {
      return false;
    }

    // Если поиск пустой, показываем все записи
    if (search.isEmpty) {
      return true;
    }

    final category = transaction.category.toLowerCase();
    final description = (transaction.description ?? '').toLowerCase();

    return category.contains(search) || description.contains(search);
  }).toList();

  // Сначала самые новые операции
  result.sort((a, b) {
    final dateResult = b.createdAt.compareTo(a.createdAt);

    if (dateResult != 0) {
      return dateResult;
    }

    return b.id.compareTo(a.id);
  });

  return result;
}

// Группировка по календарным дням
Map<DateTime, List<Transaction>> groupTransactionsByDay(
  List<Transaction> transactions,
) {
  final groups = <DateTime, List<Transaction>>{};

  for (final transaction in transactions) {
    final date = transaction.createdAt;

    final day = DateTime(date.year, date.month, date.day);

    groups.putIfAbsent(day, () => <Transaction>[]).add(transaction);
  }

  return groups;
}
