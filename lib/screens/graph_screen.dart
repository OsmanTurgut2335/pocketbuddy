import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryExpenseGraphScreen extends StatefulWidget {
  @override
  _CategoryExpenseGraphScreenState createState() => _CategoryExpenseGraphScreenState();
}

class _CategoryExpenseGraphScreenState extends State<CategoryExpenseGraphScreen> {
  Map<String, double> categoryExpenses = {};
  String categoryInput = '';  // Kullanıcıdan alınan kategori

  @override
  void initState() {
    super.initState();
  }

  // Kullanıcının girdiği kategoriye ait harcama verisini çekme
  Future<void> fetchCategoryExpenses(String category) async {
    var url = Uri.parse('http://10.0.2.2:8000/category-expenses/$category');  // API endpoint
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        // API'den dönen kategori harcama verisini alıyoruz
        categoryExpenses = {category: data['category_expenses'].toDouble()};
        print(categoryExpenses.entries);
      });
    } else {
      setState(() {
        categoryExpenses = {category: 0};  // Eğer hata varsa 0 döndür
      });
      throw Exception('API çağrısı başarısız oldu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kategori Bazında Harcama'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Text(
              'Kategori Bazında Harcama Grafiği',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20),

            // Kategori girişi için TextField
            TextField(
              onChanged: (value) {
                setState(() {
                  categoryInput = value;  // Kategori input değerini güncelle
                });
              },
              decoration: InputDecoration(
                labelText: 'Kategori Girin (örn. food, transport)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Harcama verisini çekmek için Button
            ElevatedButton(
              onPressed: () {
                if (categoryInput.isNotEmpty) {
                  fetchCategoryExpenses(categoryInput);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lütfen geçerli bir kategori girin.')),
                  );
                }
              },
              child: Text('Harcama Verisini Getir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
            ),
            SizedBox(height: 20),

            // Kategori harcama verisini bar grafiği olarak gösterme
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: categoryExpenses.values.isNotEmpty
                      ? categoryExpenses.values.reduce((a, b) => a > b ? a : b)
                      : 0.0,
                  minY: 0,
                  barGroups: categoryExpenses.entries.map((entry) {
                    return BarChartGroupData(
                      x: categoryExpenses.keys.toList().indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: Colors.blue,
                          width: 30,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          String title = categoryExpenses.keys.toList()[value.toInt()];
                          return Text(title);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
