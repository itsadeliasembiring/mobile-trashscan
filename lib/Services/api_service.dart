import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/transaction_model.dart';

class ApiService {
  final String baseUrl = 'https://api-endpoint.com/api';
  
  Future<bool> postTransaction(Transaction transaction) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(transaction.toJson()),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to post transaction. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error posting transaction: $e');
      return false;
    }
  }
  
  Future<int> getTotalPoints() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/points'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['totalPoints'] ?? 0;
      } else {
        print('Failed to get points. Status code: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('Error getting points: $e');
      return 0;
    }
  }
  
  Future<List<Transaction>> getTransactions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/transactions'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Transaction.fromJson(item)).toList();
      } else {
        print('Failed to get transactions. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }
}