class Transaction {
  final int? id;
  final String title;
  final double amount;
  final String type;
  final int categoryId;
  final DateTime date;
  final String? note;

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      type: map['type'],
      categoryId: map['categoryId'],
      date: DateTime.parse(map['date']),
      note: map['note'],
    );
  }
}
