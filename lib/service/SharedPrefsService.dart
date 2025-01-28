import 'package:shared_preferences/shared_preferences.dart';

import '../model/IncomeExpenseModel.dart';

class SharedPrefsService {
  static const _incomeExpenseKey = 'income_expense_data';

  // Veriyi SharedPreferences'e kaydetme
  static Future<void> saveIncomeExpenseData(IncomeExpenseModel data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = data.toJson();
    await prefs.setString(_incomeExpenseKey, jsonData);
  }

  // Veriyi SharedPreferences'ten alma
  static Future<IncomeExpenseModel?> getIncomeExpenseData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString(_incomeExpenseKey);
    if (jsonData != null) {
      return IncomeExpenseModel.fromJson(jsonData);
    }
    return null; // Eğer veri yoksa null döner
  }
}
