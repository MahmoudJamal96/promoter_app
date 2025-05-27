import 'package:equatable/equatable.dart';
import '../models/salary_model.dart';

class SalaryState extends Equatable {
  final bool isLoading;
  final List<SalaryModel> salaries;
  final SalaryStatsModel? stats;
  final String? errorMessage;
  final int selectedMonth;

  const SalaryState({
    this.isLoading = false,
    this.salaries = const [],
    this.stats,
    this.errorMessage,
    int? selectedMonth,
  }) : selectedMonth = selectedMonth ?? 5; // Default to May

  factory SalaryState.initial() {
    return SalaryState(
      selectedMonth: DateTime.now().month,
    );
  }

  SalaryState copyWith({
    bool? isLoading,
    List<SalaryModel>? salaries,
    SalaryStatsModel? stats,
    String? errorMessage,
    int? selectedMonth,
  }) {
    return SalaryState(
      isLoading: isLoading ?? this.isLoading,
      salaries: salaries ?? this.salaries,
      stats: stats ?? this.stats,
      errorMessage: errorMessage,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        salaries,
        stats,
        errorMessage,
        selectedMonth,
      ];
}
