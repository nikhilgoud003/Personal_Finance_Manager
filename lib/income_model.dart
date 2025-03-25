class IncomeModel {
  double _income = 0.0;

  void initialize(double initialIncome) {
    _income = initialIncome;
  }

  double get income => _income;

  void updateIncome(double newIncome) {
    _income = newIncome;
  }
}
