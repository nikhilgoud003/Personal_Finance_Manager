import 'package:flutter/material.dart';
import 'helpers/database_helper.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double currentGoal = 0.0;
  double currentIncome = 0.0;
  double totalExpense = 0.0;
  double totalInvestment = 0.0;

  @override
  void initState() {
    super.initState();
    _loadGoal();
    _loadIncome();
    _loadExpenses();
    _loadInvestments();
  }

  Future<void> _loadGoal() async {
    try {
      double goal = await DatabaseHelper.instance.getGoal() as double;
      setState(() {
        currentGoal = goal;
      });
    } catch (error) {
      print('Error loading goal: $error');
    }
  }

  Future<void> _loadIncome() async {
    try {
      double income = await DatabaseHelper.instance.getIncome() as double;
      setState(() {
        currentIncome = income;
      });
    } catch (error) {
      print('Error loading income: $error');
    }
  }

  Future<void> _loadExpenses() async {
    try {
      double expenseAmount =
          await DatabaseHelper.instance.calculateTotalExpenseAmount();
      setState(() {
        totalExpense = expenseAmount;
      });
    } catch (error) {
      print('Error loading total expenses: $error');
    }
  }

  Future<void> _loadInvestments() async {
    try {
      double investmentAmount =
          await DatabaseHelper.instance.calculateTotalInvestmentAmount();
      setState(() {
        totalInvestment = investmentAmount;
      });
    } catch (error) {
      print('Error loading total investments: $error');
    }
  }

  void _navigateToExpenseTracker(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExpenseTracker()),
    );
    await _loadExpenses();
    print('Total expenses are $totalExpense');
  }

  void _navigateToInvestmentTracker(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InvestmentTracker()),
    );
    await _loadInvestments();
    print('Total investments are $totalInvestment');
  }

  void _navigateToIncomeTracker(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Income()),
    );
    await _loadIncome();
    print('Current income is $currentIncome');
  }

  void _navigateToSavingGoal(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavingGoal()),
    );
    await _loadGoal();
    print('Current goal is $currentGoal');
  }

  void _getReport() async {
    await _loadGoal();
    await _loadIncome();
    await _loadInvestments();
    await _loadExpenses();
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Reports(
              currentIncome, totalExpense, totalInvestment, currentGoal)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Personal Finance Manager',
          style: TextStyle(color: Colors.blueGrey[800]),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[50],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blueGrey[800]),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDashboardButton(
                context,
                icon: Icons.account_balance_wallet,
                label: 'Expense Tracker',
                onPressed: () => _navigateToExpenseTracker(context),
              ),
              _buildDashboardButton(
                context,
                icon: Icons.trending_up,
                label: 'Investment Tracker',
                onPressed: () => _navigateToInvestmentTracker(context),
              ),
              _buildDashboardButton(
                context,
                icon: Icons.attach_money,
                label: 'Income Entry',
                onPressed: () => _navigateToIncomeTracker(context),
              ),
              _buildDashboardButton(
                context,
                icon: Icons.flag,
                label: 'Budget Goal Setting',
                onPressed: () => _navigateToSavingGoal(context),
              ),
              _buildDashboardButton(
                context,
                icon: Icons.pie_chart,
                label: 'Reports',
                onPressed: _getReport,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          backgroundColor: Colors.blueGrey[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 3,
        ),
        icon: Icon(icon, size: 26, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
