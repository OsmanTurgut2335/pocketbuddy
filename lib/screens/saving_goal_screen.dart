import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON verisini işlemek için

import '../widgets/app_menu.dart';

class SavingsGoalScreen extends StatefulWidget {
  final String savingGoal; // Tasarruf hedefi

  // Constructor
  SavingsGoalScreen({required this.savingGoal});

  @override
  _SavingsGoalScreenState createState() => _SavingsGoalScreenState();
}

class _SavingsGoalScreenState extends State<SavingsGoalScreen> {
  final TextEditingController _goalController = TextEditingController();
  late double savingsGoal; // Tasarruf hedefi
  String? nextMonthExpense; // Gelecek ay tahmini harcama

  @override
  void initState() {
    super.initState();
    savingsGoal = double.tryParse(widget.savingGoal) ?? 0.0;
    _goalController.text = savingsGoal.toString();
    _fetchNextMonthExpense(); // API'den veriyi al
  }

  // API'den gelecek ay harcama tahminini almak için fonksiyon
  Future<void> _fetchNextMonthExpense() async {
    final response = await http.get(Uri.parse("http://10.0.2.2:8000/predict-next-month-expenses/"));

    if (response.statusCode == 200) {
      // JSON cevabını alıp parse et
      final data = json.decode(response.body);
      print("YARRRRRRRRRRRRRRRAK");
      print(data);
      setState(() {
        nextMonthExpense = data['next_month_expenses'].toStringAsFixed(2);
      });
    } else {
      // API'den cevap alamazsak
      setState(() {
        nextMonthExpense = "Hata oluştu";
      });
    }
  }

  // Tasarruf hedefini güncelleme fonksiyonu
  void updateSavingGoal() {
    setState(() {
      savingsGoal = double.tryParse(_goalController.text) ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tasarruf Hedefi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 6.0,
        centerTitle: true,
      ),
      drawer: AppMenu(),
      body: SingleChildScrollView(  // Scrollable alan ekledik
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tasarruf Hedefi Takibi',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20),
            _buildGoalInputField(),
            SizedBox(height: 40),
            // Gelecek ay tahmini harcama
            nextMonthExpense != null
                ? Text(
              'Gelecek Ay Tahmini Harcama: $nextMonthExpense ₺',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.blueAccent,
              ),
            )
                : CircularProgressIndicator(), // API yanıtı gelene kadar loading göstergesi
            SizedBox(height: 40),
            _buildCompleteGoalButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalInputField() {
    return TextField(
      controller: _goalController,
      keyboardType: TextInputType.number,
      onChanged: (text) {
        updateSavingGoal();
      },
      decoration: InputDecoration(
        labelText: 'Tasarruf Hedefi (₺)',
        hintText: 'Örneğin: 1000 ₺',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
      ),
    );
  }

  Widget _buildCompleteGoalButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Tasarruf hedefini tamamlamak için kaydet
        Navigator.pop(context, _goalController.text);
      },
      child: Text('Hedefi Tamamla', style: TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30),
        textStyle: TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 8,
      ),
    );
  }
}
