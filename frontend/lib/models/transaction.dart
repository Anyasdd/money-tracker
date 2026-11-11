class Transaction {
  final int id;
  final String type;
  final String amount;
  final String category;
  final String? description;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.createdAt,
  });

  bool get isIncome => type == 'income';

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      type: json['type'] as String,
      amount: json['amount'].toString(),
      category: json['category'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(
        json['created_at'] as String,
      ).toLocal(),
    );
  }
}