class Transaction {
  final String id;
  final String type;
  final String title;
  final int points;
  final DateTime dateTime;
  final String? redemptionCode;

  Transaction({
    required this.id,
    required this.type,
    required this.title,
    required this.points,
    required this.dateTime,
    this.redemptionCode,
  });

    Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'points': points,
      'dateTime': dateTime.toIso8601String(),
      if (redemptionCode != null) 'redemptionCode': redemptionCode,
    };
  }

    // (Opsional) Untuk parsing dari API
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      points: json['points'],
      dateTime: DateTime.parse(json['dateTime']),
      redemptionCode: json['redemptionCode'],
    );
  }
}