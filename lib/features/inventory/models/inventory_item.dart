class InventoryItem {
  final String id;
  final String name;
  final double primaryUnitCount;
  final double secondaryUnitCount;
  final String primaryUnit;
  final String secondaryUnit;
  final double price;
  final double actualCount; // For recording actual inventory count

  InventoryItem({
    required this.id,
    required this.name,
    required this.primaryUnitCount,
    required this.secondaryUnitCount,
    required this.primaryUnit,
    required this.secondaryUnit,
    required this.price,
    this.actualCount = 0,
  });

  double get totalValue => price * primaryUnitCount;

  double get difference => actualCount - primaryUnitCount;

  bool get hasDifference => difference != 0;

  InventoryItem copyWith({
    String? id,
    String? name,
    double? primaryUnitCount,
    double? secondaryUnitCount,
    String? primaryUnit,
    String? secondaryUnit,
    double? price,
    double? actualCount,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryUnitCount: primaryUnitCount ?? this.primaryUnitCount,
      secondaryUnitCount: secondaryUnitCount ?? this.secondaryUnitCount,
      primaryUnit: primaryUnit ?? this.primaryUnit,
      secondaryUnit: secondaryUnit ?? this.secondaryUnit,
      price: price ?? this.price,
      actualCount: actualCount ?? this.actualCount,
    );
  }
}
