abstract class CurrencyConverter {
  Future<double> convert(
    double amount,
    String fromCurrency,
    String toCurrency,
  );
  
  Future<Map<String, double>> getExchangeRates(String baseCurrency);
  
  Future<List<String>> getSupportedCurrencies();
} 