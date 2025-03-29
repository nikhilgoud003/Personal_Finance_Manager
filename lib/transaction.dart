class Transaction {
  String _id;
  String _title;
  double _amount;
  String _category;
  DateTime _date;

  String get txnId => _id;
  String get txnTitle => _title;
  double get txnAmount => _amount;
  String get txnCategory => _category;
  DateTime get txnDateTime => _date;

  // Constructor with initialization of all fields
  Transaction(
    this._id,
    this._title,
    this._amount, // Initialize _amount in the constructor parameters
    this._category,
    this._date,
  );

  // Convenience constructor to create a Transaction object from a map
  Transaction.fromMap(Map<String, dynamic> map)
      : _id = map['id'].toString(),
        _title = map['title'],
        _amount = map['amount'] ??
            0.0, // Provide a default value if map['amount'] is null
        _category = map['category'],
        _date = DateTime.parse(map['date']);

  // Convenience method to create a map from this Transaction object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': int.tryParse(_id),
      'title': _title,
      'amount': _amount,
      'category': _category,
      'date': _date.toIso8601String(),
    };
    //if (_id != null) {
    map['id'] = int.tryParse(_id);
    //}

    return map;
  }
}
