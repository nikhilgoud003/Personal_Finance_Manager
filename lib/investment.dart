class Investment {
  String _id;
  String _title;
  double _amount;
  DateTime _date;

  String get invId => _id;
  String get invTitle => _title;
  double get invAmount => _amount;
  DateTime get invDateTime => _date;

  // Constructor with initialization of all fields
  Investment(
    this._id,
    this._title,
    this._amount, // Initialize _amount in the constructor parameters
    this._date,
  );

  // Convenience constructor to create a Transaction object from a map
  Investment.fromMap(Map<String, dynamic> map)
      : _id = map['id'].toString(),
        _title = map['title'],
        _amount = map['amount'] ??
            0.0, // Provide a default value if map['amount'] is null
        _date = DateTime.parse(map['date']);

  // Convenience method to create a map from this Transaction object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': int.tryParse(_id),
      'title': _title,
      'amount': _amount,
      'date': _date.toIso8601String(),
    };
    //if (_id != null) {
    map['id'] = int.tryParse(_id);
    //}

    return map;
  }
}
