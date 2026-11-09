import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/balance.dart';

class BalanceRepository {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  Future<Balance> fetchBalance() async {
    final url = Uri.parse('$baseUrl/balance');

    final response = await http.get(url).timeout(
      const Duration(seconds: 10),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body)
          as Map<String, dynamic>;

      return Balance.fromJson(json);
    } else {
      throw Exception(
        'Failed to load balance: ${response.statusCode}',
      );
    }
  }
}