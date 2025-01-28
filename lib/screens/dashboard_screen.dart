import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pocket_body/screens/saving_goal_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_menu.dart';
import 'chatbot_screen.dart';
import 'graph_screen.dart';
import 'income_expense_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ValueNotifier<String> income = ValueNotifier<String>('5000 ₺');
  ValueNotifier<String> expense = ValueNotifier<String>('0 ₺'); // Başlangıçta gider 0 ₺
  ValueNotifier<String> savingGoal = ValueNotifier<String>('1000 ₺');



  @override
  void initState() {
    super.initState();
    _loadData(); // Gelir ve tasarruf hedefi verilerini yükle
    _fetchExpense(); // Gideri API'den al
  }

  // Gelir ve Tasarruf Hedefi verilerini SharedPreferences'ten yükleyen fonksiyon
  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedIncome = prefs.getString('income') ?? '0 ₺';
    String storedSavingGoal = prefs.getString('savingGoal') ?? '1000 ₺';

    income.value = storedIncome;
    savingGoal.value = storedSavingGoal;
  }

  Future<void> _fetchExpense() async {
    try {
      // API'ye GET isteği gönderiyoruz
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/current-month-expenses/'));

      // Eğer yanıt başarılıysa (HTTP 200)
      if (response.statusCode == 200) {
        // Gelen JSON verisini işleyin
        var data = jsonDecode(response.body);
        // 'current_month_expenses' anahtarını kullanarak veriyi alıyoruz
        String fetchedExpense = data['current_month_expenses'].toString() + ' ₺';
        setState(() {
          expense.value = fetchedExpense; // Gider değerini güncelle
        });
      } else {
        // Hata durumu
        print('API isteği başarısız oldu: ${response.statusCode}');
      }
    } catch (e) {
      // Hata durumunda
      print('API isteği hatası: $e');
    }
  }

  // Verileri SharedPreferences'e kaydetme fonksiyonu
  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('income', income.value);
    await prefs.setString('savingGoal', savingGoal.value);
  }

  // Gelir ve gider farkını hesaplayan fonksiyon
  double get savingsDifference {
    double incomeValue = double.tryParse(income.value.split(' ')[0]) ?? 0.0;
    double expenseValue = double.tryParse(expense.value.split(' ')[0]) ?? 0.0;
    return incomeValue - expenseValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Pocket Buddy'),
        elevation: 4.0,
      ),
      drawer: AppMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Gelir ve Gider Özetiniz',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20),
            ValueListenableBuilder<String>(
              valueListenable: income,
              builder: (context, value, child) {
                return _buildFinancialCard('Gelir', value, Colors.green);
              },
            ),
            SizedBox(height: 16),
            ValueListenableBuilder<String>(
              valueListenable: expense,
              builder: (context, value, child) {
                return _buildFinancialCard('Gider', value, Colors.red);
              },
            ),
            SizedBox(height: 16),
            ValueListenableBuilder<String>(
              valueListenable: savingGoal,
              builder: (context, value, child) {
                return _buildFinancialCard('Tasarruf Hedefi', value, Colors.orange);
              },
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IncomeExpenseScreen()),
                );

                if (result != null && result is Map<String, String>) {
                  final category = result['category'];
                  final amount = result['amount'];

                  // Update values based on income/expense category
                  if (category == 'Gelir') {
                    income.value = '${int.parse(income.value.split(' ')[0]) + int.parse(amount!)} ₺';
                  } else if (category == 'Gider') {
                    expense.value = '${int.parse(expense.value.split(' ')[0]) + int.parse(amount!)} ₺';
                  }

                  // Save updated data
                  await _saveData();
                  // Reload the data from SharedPreferences
                  _loadData();
                }
              },
              icon: Icon(Icons.add),
              label: Text('Gelir/Gider Ekle'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                iconColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton('Grafikler', Icons.bar_chart, context, CategoryExpenseGraphScreen()),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SavingsGoalScreen(
                          // Gelir-Gider farkı
                          savingGoal: savingGoal.value, // Tasarruf hedefi
                        ),
                      ),
                    );

                    if (result != null && result is String) {
                      savingGoal.value = result;
                      await _saveData();
                    }
                  },
                  icon: Icon(Icons.trending_up),
                  label: Text('Hedefler'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                    iconColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatbotScreen()),
          );
        },
        child: Icon(Icons.chat),
        backgroundColor: Colors.blueAccent,
        tooltip: 'Chatbot',
      ),
    );
  }

  Widget _buildFinancialCard(String title, String amount, Color color) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        leading: Icon(
          Icons.account_balance_wallet,
          color: color,
          size: 40,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          amount,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, BuildContext context, Widget screen) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30),
        iconColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
