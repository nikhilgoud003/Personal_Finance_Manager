import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'income_model.dart';

class Income extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final IncomeModel incomeModel = IncomeModel(); // Initialize IncomeModel

  TextEditingController _incomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadIncomeFromDatabase();
  }

  Future<void> _loadIncomeFromDatabase() async {
    try {
      double? savedIncome = await DatabaseHelper.instance.getIncome();
      if (savedIncome != null) {
        incomeModel.updateIncome(savedIncome);
        setState(() {});
      } else {
        // No saved goal found, set an initial default goal
        incomeModel.initialize(0.0); // Set your initial default goal here
        setState(() {}); // Update UI to reflect the initial goal
      }
    } catch (e) {
      print('Error loading income: $e');
      // Handle error as needed
    }
  }

  void _saveIncome(BuildContext context) async {
    double newIncome = double.tryParse(_incomeController.text) ?? 0.0;
    incomeModel.updateIncome(newIncome);

    // Check if goal exists in database
    double? savedIncome = await DatabaseHelper.instance.getIncome();

    try {
      if (savedIncome != null) {
        // Goal exists, update it
        await DatabaseHelper.instance.updateIncome(newIncome);
      } else {
        // Goal doesn't exist, insert new goal
        await DatabaseHelper.instance.insertIncome(newIncome);
      }

      setState(() {}); // Update UI after saving or updating goal

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Income saved: \$${newIncome.toStringAsFixed(2)}')),
      );
    } catch (error) {
      print('Error saving income: $error');
      // Handle error, e.g., show an error message to the user
    }
    // Save income logic here
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Income Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Current Income: \$${incomeModel.income.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _incomeController,
              decoration: InputDecoration(
                labelText: 'Enter New Income',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _saveIncome(context),
              child: Text('Save Income'),
            ),
          ],
        ),
      ),
    );
  }
}
