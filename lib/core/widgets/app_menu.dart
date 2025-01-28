import 'package:flutter/material.dart';
import 'package:pocket_body/screens/graph_screen.dart';

import '../../screens/dashboard_screen.dart';
import '../../screens/income_expense_screen.dart';


class AppMenu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blueAccent,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Menünün başlığı (DrawerHeader)
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
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
            _buildMenuTile(context, 'Ana Ekran', Icons.home, DashboardScreen()),
            _buildMenuTile(context, 'Gelir/Gider Ekle', Icons.add, IncomeExpenseScreen()),
            _buildMenuTile(context, 'Grafikler ve Görselleştirme', Icons.bar_chart, CategoryExpenseGraphScreen()),
          //  _buildMenuTile(context, 'Tasarruf Hedefi', Icons.trending_up, SavingsGoalScreen()),
          ],
        ),
      ),
    );
  }


  Widget _buildMenuTile(BuildContext context, String title, IconData icon, Widget screen) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white, //
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
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
