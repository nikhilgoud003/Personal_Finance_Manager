import 'package:flutter/material.dart';
import './helpers/database_helper.dart';

class SavingGoal extends StatelessWidget {
  const SavingGoal({super.key});

  @override
  Widget build(BuildContext context) {
    return const GoalHomePage();
  }
}

class GoalHomePage extends StatefulWidget {
  const GoalHomePage({super.key});

  @override
  _GoalHomePageState createState() => _GoalHomePageState();
}

class _GoalHomePageState extends State<GoalHomePage> {
  final GoalModel goalModel = GoalModel(); // Initialize GoalModel

  final TextEditingController _goalController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadGoalFromDatabase();
    // Initialize with a default goal value (e.g., 0.0)
  }

  Future<void> _loadGoalFromDatabase() async {
    try {
      double? savedGoal = await DatabaseHelper.instance.getGoal();
      if (savedGoal != null) {
        goalModel.updateGoal(savedGoal);
        setState(() {});
      } else {
        // No saved goal found, set an initial default goal
        goalModel.initialize(0.0); // Set your initial default goal here
        setState(() {}); // Update UI to reflect the initial goal
      }
    } catch (e) {
      print('Error loading goal: $e');
      // Handle error as needed
    }
  }

  // Save goal action
  void _saveGoal(BuildContext context) async {
    double newGoal = double.tryParse(_goalController.text) ?? 0.0;
    goalModel.updateGoal(newGoal);

    // Check if goal exists in database
    double? savedGoal = await DatabaseHelper.instance.getGoal();

    try {
      if (savedGoal != null) {
        // Goal exists, update it
        await DatabaseHelper.instance.updateGoal(newGoal);
      } else {
        // Goal doesn't exist, insert new goal
        await DatabaseHelper.instance.insertGoal(newGoal);
      }

      setState(() {}); // Update UI after saving or updating goal

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Goal saved: \$${newGoal.toStringAsFixed(2)}')),
      );
    } catch (error) {
      print('Error saving goal: $error');
      // Handle error, e.g., show an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Savings Goal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Current Goal: \$${goalModel._goal.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _goalController,
              decoration: const InputDecoration(
                labelText: 'Enter New Goal',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _saveGoal(context),
              child: const Text('Save Goal'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }
}

class GoalModel {
  double _goal = 0.0;

  void initialize(double initialGoal) {
    _goal = initialGoal;
  }

  double get goal => _goal;

  void updateGoal(double newGoal) {
    _goal = newGoal;
  }
}
