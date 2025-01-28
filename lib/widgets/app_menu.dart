import 'package:flutter/material.dart';
import 'package:pocket_body/screens/graph_screen.dart';
import '../screens/income_expense_screen.dart';

import '../screens/dashboard_screen.dart'; // DashboardScreen için gerekli import

class AppMenu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blueAccent, // Menünün arka plan rengi
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Menünün başlığı (DrawerHeader)
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent, // Başlık arka plan rengi
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.account_balance_wallet, // Uygulama simgesi
                    color: Colors.white,
                    size: 40,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Pocket Buddy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Kişisel Finans Yardımcınız',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Menü öğeleri
            _buildMenuTile(context, 'Ana Ekran', Icons.home, DashboardScreen()), // Ana Ekran menü öğesi
            _buildMenuTile(context, 'Gelir/Gider Ekle', Icons.add, IncomeExpenseScreen()),
            _buildMenuTile(context, 'Grafikler ve Görselleştirme', Icons.bar_chart, CategoryExpenseGraphScreen()),
          //  _buildMenuTile(context, 'Tasarruf Hedefi', Icons.trending_up, SavingsGoalScreen()),
          ],
        ),
      ),
    );
  }

  // Menü öğesi için şık bir ListTile widget'ı
  Widget _buildMenuTile(BuildContext context, String title, IconData icon, Widget screen) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white, // Icon'un rengi beyaz
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white, // Metin rengi beyaz
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }

}
