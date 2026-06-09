class BillRecord {
  int? id;
  String month;
  double units;
  double rebatePercent;
  double totalCharges;
  double finalCost;
  String createdAt;

  BillRecord({
    this.id,
    required this.month,
    required this.units,
    required this.rebatePercent,
    required this.totalCharges,
    required this.finalCost,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'month': month,
        'units': units,
        'rebate_percent': rebatePercent,
        'total_charges': totalCharges,
        'final_cost': finalCost,
        'created_at': createdAt,
      };

  factory BillRecord.fromMap(Map<String, dynamic> map) => BillRecord(
        id: map['id'],
        month: map['month'],
        units: map['units'],
        rebatePercent: map['rebate_percent'],
        totalCharges: map['total_charges'],
        finalCost: map['final_cost'],
        createdAt: map['created_at'],
      );

  BillRecord copyWith({
    int? id,
    String? month,
    double? units,
    double? rebatePercent,
    double? totalCharges,
    double? finalCost,
    String? createdAt,
  }) =>
      BillRecord(
        id: id ?? this.id,
        month: month ?? this.month,
        units: units ?? this.units,
        rebatePercent: rebatePercent ?? this.rebatePercent,
        totalCharges: totalCharges ?? this.totalCharges,
        finalCost: finalCost ?? this.finalCost,
        createdAt: createdAt ?? this.createdAt,
      );
}
