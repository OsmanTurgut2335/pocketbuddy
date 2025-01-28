import 'dart:convert';

class IncomeExpenseModel {
  final Map<String, double> incomeMap;
  final Map<String, double> expenseMap;

  IncomeExpenseModel({
    required this.incomeMap,
    required this.expenseMap,
  });

  // JSON'dan IncomeExpenseModel oluşturma
  factory IncomeExpenseModel.fromJson(String jsonData) {
    final Map<String, dynamic> data = json.decode(jsonData);
    return IncomeExpenseModel(
      incomeMap: Map<String, double>.from(data['incomeMap']),
      expenseMap: Map<String, double>.from(data['expenseMap']),
    );
  }

  // IncomeExpenseModel'i JSON formatına dönüştürme
  String toJson() {
    final data = {
      'incomeMap': incomeMap,
      'expenseMap': expenseMap,
    };
    return json.encode(data);
  }
}
