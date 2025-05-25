import 'package:equatable/equatable.dart';
import '../models/salary_model.dart';

abstract class SalaryState extends Equatable {
  const SalaryState();

  @override
  List<Object?> get props => [];
}

class SalaryInitial extends SalaryState {}

class SalaryLoading extends SalaryState {}

class SalaryLoaded extends SalaryState {
  final List<SalaryModel> salaries;
  final SalaryModel? currentSalary;
  final SalaryStatsModel? salaryStats;
  final Map<String, dynamic>? userInfo;
  final DateTime selectedMonth;
  final List<SalaryModel> filteredSalaries;
  final List<String> availableMonths;

  const SalaryLoaded({
    required this.salaries,
    this.currentSalary,
    this.salaryStats,
    this.userInfo,
    required this.selectedMonth,
    List<SalaryModel>? filteredSalaries,
    List<String>? availableMonths,
  })  : filteredSalaries = filteredSalaries ?? salaries,
        availableMonths = availableMonths ?? const [];

  // Get current month salary
  SalaryModel? get currentMonthSalary {
    final currentMonthStr =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    try {
      return salaries.firstWhere(
        (salary) => salary.month == currentMonthStr,
      );
    } catch (e) {
      return salaries.isNotEmpty ? salaries.first : null;
    }
  }

  // Get salary history (excluding current month)
  List<SalaryModel> get salaryHistory {
    final currentMonthStr =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    return salaries.where((salary) => salary.month != currentMonthStr).toList()
      ..sort((a, b) => b.month.compareTo(a.month)); // Sort by month descending
  }

  SalaryLoaded copyWith({
    List<SalaryModel>? salaries,
    SalaryModel? currentSalary,
    SalaryStatsModel? salaryStats,
    Map<String, dynamic>? userInfo,
    DateTime? selectedMonth,
    List<SalaryModel>? filteredSalaries,
    List<String>? availableMonths,
  }) {
    return SalaryLoaded(
      salaries: salaries ?? this.salaries,
      currentSalary: currentSalary ?? this.currentSalary,
      salaryStats: salaryStats ?? this.salaryStats,
      userInfo: userInfo ?? this.userInfo,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      filteredSalaries: filteredSalaries ?? this.filteredSalaries,
      availableMonths: availableMonths ?? this.availableMonths,
    );
  }

  @override
  List<Object?> get props => [
        salaries,
        currentSalary,
        salaryStats,
        userInfo,
        selectedMonth,
        filteredSalaries,
        availableMonths,
      ];
}

class SalaryUpdating extends SalaryState {
  final SalaryLoaded currentState;

  const SalaryUpdating(this.currentState);

  @override
  List<Object?> get props => [currentState];
}

class SalaryError extends SalaryState {
  final String message;
  final SalaryLoaded? previousState;

  const SalaryError({
    required this.message,
    this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}

class SalaryPaymentRequesting extends SalaryState {
  final SalaryLoaded currentState;

  const SalaryPaymentRequesting(this.currentState);

  @override
  List<Object?> get props => [currentState];
}

class SalaryPaymentRequested extends SalaryState {
  final SalaryLoaded updatedState;

  const SalaryPaymentRequested(this.updatedState);

  @override
  List<Object?> get props => [updatedState];
}
