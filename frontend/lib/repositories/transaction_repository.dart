import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/transaction.dart';

class TransactionRepository {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  Future<List<Transaction>> fetchTransactions() async {
    final url = Uri.parse('$baseUrl/transactions');

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data =
          jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;

      return data.map((json) {
        return Transaction.fromJson(json as Map<String, dynamic>);
      }).toList();
    } else {
      throw Exception('Failed to load transactions: ${response.statusCode}');
    }
  }

  // Добавление новой транзакции
  Future<Transaction> createTransaction({
    required String type,
    required String amount,
    required String category,
    String? description,
  }) async {
    final url = Uri.parse('$baseUrl/transactions');

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode({
            'type': type,
            'amount': amount,
            'category': category,
            'description': description,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      final json =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      return Transaction.fromJson(json);
    } else {
      throw Exception('Failed to create transaction: ${response.statusCode}');
    }
  }
}
