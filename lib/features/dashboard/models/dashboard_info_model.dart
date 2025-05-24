class DashboardInfo {
  final double totalDebt;
  final double completionPercentage;
  final String currencySymbol;

  DashboardInfo({
    required this.totalDebt,
    required this.completionPercentage,
    this.currencySymbol = 'جنيه',
  });

  factory DashboardInfo.fromJson(Map<String, dynamic> json) {
    return DashboardInfo(
      totalDebt: (json['total_dept'] as num).toDouble(),
      completionPercentage: (json['target'] as num).toDouble(),
      currencySymbol: 'جنيه',
    );
  }
}
