import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/currency_converter.dart';

class CurrencyConverterImpl implements CurrencyConverter {
  final String apiKey;
  final String baseUrl = 'https://v6.exchangerate-api.com/v6';

  CurrencyConverterImpl({required this.apiKey});

  @override
  Future<double> convert(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) async {
    if (fromCurrency == toCurrency) return amount;
    
    final response = await http.get(
      Uri.parse('$baseUrl/$apiKey/pair/$fromCurrency/$toCurrency/$amount'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['conversion_result'];
    } else {
      throw Exception('Failed to convert currency');
    }
  }

  @override
  Future<Map<String, double>> getExchangeRates(String baseCurrency) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$apiKey/latest/$baseCurrency'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Map<String, double>.from(data['conversion_rates']);
    } else {
      throw Exception('Failed to get exchange rates');
    }
  }

  @override
  Future<List<String>> getSupportedCurrencies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/$apiKey/codes'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> codes = data['supported_codes'];
      return codes.map((code) => code[0] as String).toList();
    } else {
      throw Exception('Failed to get supported currencies');
    }
  }
} 