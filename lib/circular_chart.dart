import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart'; // Import the pie_chart package
import 'transaction.dart';

class CategoryChart extends StatelessWidget {
  final List<Transaction> _recentTransactions;
  final Map<String, double> _categoryTotals = {};

  CategoryChart(this._recentTransactions) {
    _calculateCategoryTotals();
  }

  void _calculateCategoryTotals() {
    _recentTransactions.forEach((transaction) {
      if (_categoryTotals.containsKey(transaction.txnCategory)) {
        _categoryTotals[transaction.txnCategory] =
            (_categoryTotals[transaction.txnCategory] ?? 0.0) +
                transaction.txnAmount;
      } else {
        _categoryTotals[transaction.txnCategory] = transaction.txnAmount;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _categoryTotals.isNotEmpty
        ? Column(
            children: [
              Expanded(
                child: PieChart(
                  dataMap: _categoryTotals,
                  chartRadius: MediaQuery.of(context).size.width / 2.7,
                  chartType: ChartType.disc,
                  legendOptions: LegendOptions(
                    legendPosition: LegendPosition.right,
                    showLegendsInRow: false,
                    legendTextStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 8,
                    ),
                  ),
                ),
              ),
            ],
          )
        /*PieChart(
            dataMap: _categoryTotals,
            chartRadius: MediaQuery.of(context).size.width / 2.7,
            chartType: ChartType.disc,
            legendOptions: LegendOptions(
              legendPosition: LegendPosition.right,
              showLegendsInRow: true,
              legendTextStyle: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          )*/
        : Center(
            child: Text(
              'No data to display',
              style: TextStyle(fontSize: 16),
            ),
          );
  }
}
