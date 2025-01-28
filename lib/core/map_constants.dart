
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MapConstants{
  ValueNotifier<String> income = ValueNotifier<String>('5000 ₺');
  ValueNotifier<String> expense = ValueNotifier<String>('3000 ₺');
  ValueNotifier<String> savingGoal = ValueNotifier<String>('1000 ₺');
  // Load data from SharedPreferences
  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedIncome = prefs.getString('income') ?? '5000 ₺';
    String storedExpense = prefs.getString('expense') ?? '3000 ₺';
    String storedSavingGoal = prefs.getString('savingGoal') ?? '1000 ₺';

    income.value = storedIncome;
    expense.value = storedExpense;
    savingGoal.value = storedSavingGoal;
  }
  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('income', income.value);
    await prefs.setString('expense', expense.value);
    await prefs.setString('savingGoal', savingGoal.value);
  }
}