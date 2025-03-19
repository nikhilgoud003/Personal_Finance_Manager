import 'dart:io';
import 'package:flutter/material.dart';
import 'package:PersonalFinanceManager/models/investment.dart';
import './widgets/new_investment_form.dart';
import './widgets/investment_list.dart';
import './helpers/database_helper.dart';

class InvestmentTracker extends StatelessWidget {
  const InvestmentTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Investment> _userInvestments = [];
  bool _showChart = false;

  List<Investment> get _recentInvestments {
    DateTime lastDayOfPrevWeek =
        DateTime.now().subtract(const Duration(days: 6));
    lastDayOfPrevWeek = DateTime(
        lastDayOfPrevWeek.year, lastDayOfPrevWeek.month, lastDayOfPrevWeek.day);
    return _userInvestments.where((element) {
      return element.invDateTime.isAfter(
        lastDayOfPrevWeek,
      );
    }).toList();
  }

  _MyHomePageState() {
    _updateUserInvestmentsList();
  }

  void _updateUserInvestmentsList() {
    Future<List<Investment>> res = DatabaseHelper.instance.getAllInvestments();

    res.then((invList) {
      setState(() {
        _userInvestments = invList;
      });
    });
  }

  void _showChartHandler(bool show) {
    setState(() {
      _showChart = show;
    });
  }

  Future<void> _addNewInvestment(
      String title, double amount, DateTime chosenDate) async {
    final newInv = Investment(
      DateTime.now().millisecondsSinceEpoch.toString(),
      title,
      amount,
      chosenDate,
    );
    int res = await DatabaseHelper.instance.insertInvestment(newInv);

    if (res != 0) {
      _updateUserInvestmentsList();
    }
  }

  void _startAddNewInvestment(BuildContext context) {
    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.80,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
          ),
          child: NewInvestmentForm(_addNewInvestment),
        );
      },
    );
  }

  Future<void> _deleteInvestment(String id) async {
    int parsedId =
        int.tryParse(id) ?? 0; // Use 0 as default value if parsing fails
    int res = await DatabaseHelper.instance.deleteInvestmentById(parsedId);
    if (res != 0) {
      _updateUserInvestmentsList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppBar myAppBar = AppBar(
      title: const Text(
        'Personal Investments',
        style: TextStyle(
          fontFamily: "Quicksand",
          fontWeight: FontWeight.w400,
          fontSize: 20.0,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _startAddNewInvestment(context),
          tooltip: "Add New Investment",
        ),
      ],
    );
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    final bool isLandscape =
        mediaQueryData.orientation == Orientation.landscape;

    final double availableHeight = mediaQueryData.size.height -
        myAppBar.preferredSize.height -
        mediaQueryData.padding.top -
        mediaQueryData.padding.bottom;

    final double availableWidth = mediaQueryData.size.width -
        mediaQueryData.padding.left -
        mediaQueryData.padding.right;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: myAppBar,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (isLandscape)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Show Chart",
                    style: TextStyle(
                      fontFamily: "Rubik",
                      fontSize: 16.0,
                      color: Colors.grey[500],
                    ),
                  ),
                  Switch.adaptive(
                    activeColor: Colors.amber[700],
                    value: _showChart,
                    onChanged: (value) => _showChartHandler(value),
                  ),
                ],
              ),
            if (isLandscape)
              /*_showChart
                  ? myCircularChartContainer(
                      height: availableHeight * 0.8,
                      width: 0.6 * availableWidth)
                  :*/
              myInvestmentListContainer(
                  height: availableHeight * 0.8, width: 0.6 * availableWidth),
            //if (!isLandscape)
            //myCircularChartContainer(
            //  height: availableHeight * 0.2, width: availableWidth),
            //CategoryChart(_recentTransactions),
            //myChartContainer(
            //  height: availableHeight * 0.3, width: availableWidth),
            if (!isLandscape)
              myInvestmentListContainer(
                  height: availableHeight * 0.7, width: availableWidth),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Platform.isIOS
          ? Container()
          : FloatingActionButton(
              tooltip: "Add New Investment",
              onPressed: () => _startAddNewInvestment(context),
              child: const Icon(Icons.add),
            ),
    );
  }

  /*Widget myCircularChartContainer({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      child: CategoryChart(_userInvestments),
    );
  }*/

  /* Widget myChartContainer({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      child: Chart(_recentTransactions),
    );
  }*/

  Widget myInvestmentListContainer(
      {required double height, required double width}) {
    return SizedBox(
      height: height,
      width: width,
      child: InvestmentList(_userInvestments, _deleteInvestment),
    );
  }
}
