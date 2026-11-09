class Balance {
  final String totalIncome;
  final String totalExpense;
  final String balance;
  final int transactionCount;

  Balance({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
  });

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      totalIncome: json['total_income'].toString(),
      totalExpense: json['total_expense'].toString(),
      balance: json['balance'].toString(),
      transactionCount: json['transaction_count'] as int,
    );
  }
}