import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/IncomeExpenseModel.dart';
import '../core/SharedPrefsService.dart';

class IncomeExpenseScreen extends StatefulWidget {
  @override
  _IncomeExpenseScreenState createState() => _IncomeExpenseScreenState();
}

class _IncomeExpenseScreenState extends State<IncomeExpenseScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController categoryController = TextEditingController(); // Kategori için controller
  String selectedTransactionType = 'Gelir'; // Default income/expense
  IncomeExpenseModel _incomeExpenseData = IncomeExpenseModel(incomeMap: {}, expenseMap: {});

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double amount = double.tryParse(amountController.text) ?? 0.0;
    String category = categoryController.text.trim();

    if (amount <= 0.0 || category.isEmpty) {
      // Geçersiz bir miktar veya kategori girildiyse uyarı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Geçerli bir miktar ve kategori girin")),
      );
      return;
    }


if(selectedTransactionType == 'Gelir'){
  // SharedPreferences'ten mevcut gelir/gider verilerini al
  String existingData = prefs.getString(selectedTransactionType == 'Gelir'
      ? 'income'
      : 'expense') ?? '0.0';

  // Eski veriyi double'a çevir
  double existingAmount = double.tryParse(existingData) ?? 0.0;

  // Yeni veriyi mevcut veriye ekle
  double updatedAmount = existingAmount + amount;


  // Yeni değeri SharedPreferences'e kaydet
  if (selectedTransactionType == 'Gelir') {
    await prefs.setString('income', updatedAmount.toString());
    // Gelir modelini güncelle
    _incomeExpenseData.incomeMap[category] = updatedAmount;
  } else {
    await prefs.setString('expense', updatedAmount.toString());
    // Gider modelini güncelle
    _incomeExpenseData.expenseMap[category] = updatedAmount;
  }

  // Veriyi SharedPreferences'e kaydet

  await SharedPrefsService.saveIncomeExpenseData(_incomeExpenseData);

  Navigator.pop(context, {
    'category': selectedTransactionType,
    'amount': amountController.text,
  });

}
  else{
  // API'ye POST isteği gönder
  var url = Uri.parse('http://10.0.2.2:8000/add-expense/');
  var response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: json.encode({
      'amount': amount,
      'category': category,
    }),
  );

  // Yanıtı kontrol et
  if (response.statusCode == 200) {
    // Başarılıysa mesaj göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Veri başarıyla gönderildi!")),
    );
  } else {
    // Hata durumunda mesaj göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Hata oluştu, tekrar deneyin.")),
    );
  }
}
    // UI'yi güncelle
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Gelir/Gider Ekle"),
        elevation: 4.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Gelir/Gider Bilgilerini Girin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20),
            // Gelir ve Gider seçeneğini RadioButton ile ekliyoruz
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Gelir'),
                    value: 'Gelir',
                    groupValue: selectedTransactionType,
                    onChanged: (value) {
                      setState(() {
                        selectedTransactionType = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Gider'),
                    value: 'Gider',
                    groupValue: selectedTransactionType,
                    onChanged: (value) {
                      setState(() {
                        selectedTransactionType = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Miktar girişini sağlayan TextField
            _buildInputField('Miktar', TextInputType.number, amountController),
            SizedBox(height: 20),
            // Kategori girişini sağlayan TextField
            _buildInputField('Kategori', TextInputType.text, categoryController),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveData,
              child: Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextInputType inputType, TextEditingController controller) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          controller: controller,
          keyboardType: inputType,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blueAccent),
            ),
          ),
        ),
      ),
    );
  }
}
