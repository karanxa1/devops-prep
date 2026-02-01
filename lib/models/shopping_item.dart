class ShoppingItem {
  final int? id;
  final String name;
  final String quantity;
  final String unit;
  final String category;
  final bool isChecked;
  final DateTime weekStart;

  ShoppingItem({
    this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    this.isChecked = false,
    required this.weekStart,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'isChecked': isChecked ? 1 : 0,
      'weekStart': weekStart.toIso8601String().split('T')[0],
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      unit: map['unit'],
      category: map['category'],
      isChecked: map['isChecked'] == 1,
      weekStart: DateTime.parse(map['weekStart']),
    );
  }

  ShoppingItem copyWith({
    int? id,
    String? name,
    String? quantity,
    String? unit,
    String? category,
    bool? isChecked,
    DateTime? weekStart,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      isChecked: isChecked ?? this.isChecked,
      weekStart: weekStart ?? this.weekStart,
    );
  }
}
