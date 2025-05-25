import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/salary_model.dart';
import '../services/salary_service.dart';
import 'salary_state.dart';

class SalaryCubit extends Cubit<SalaryState> {
  final SalaryService _salaryService;

  SalaryCubit({SalaryService? salaryService})
      : _salaryService = salaryService ?? SalaryService(),
        super(SalaryInitial());

  // Load salaries for a specific month
  Future<void> loadSalaries({DateTime? month}) async {
    emit(SalaryLoading());

    try {
      final selectedMonth = month ?? DateTime.now();
      final monthStr =
          '${selectedMonth.year}-${selectedMonth.month.toString().padLeft(2, '0')}';
      // Load salaries for the specified month
      final salaries = await _salaryService.getSalaries(
        startDate: monthStr + '-01',
        endDate: monthStr + '-31',
      );

      // Find current month salary
      final currentMonthStr =
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
      SalaryModel? currentSalary;

      try {
        currentSalary = salaries.firstWhere(
          (salary) => salary.month == currentMonthStr,
        );
      } catch (e) {
        currentSalary = salaries.isNotEmpty ? salaries.first : null;
      } // Load additional data
      final userInfo = await _salaryService.getUserInfo();
      final salaryStats = await _salaryService.getSalaryStats();

      // Generate available months from salaries
      final availableMonths = salaries
          .map((salary) => salary.month)
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a)); // Sort descending (newest first)

      // Filter salaries for selected month
      final filteredSalaries =
          salaries.where((salary) => salary.month == monthStr).toList();

      emit(SalaryLoaded(
        salaries: salaries,
        currentSalary: currentSalary,
        salaryStats: salaryStats,
        userInfo: userInfo,
        selectedMonth: selectedMonth,
        filteredSalaries: filteredSalaries,
        availableMonths: availableMonths,
      ));
    } catch (e) {
      emit(SalaryError(
        message: 'Failed to load salaries: ${e.toString()}',
      ));
    }
  }

  // Load salary for a specific month
  Future<void> loadSalaryForMonth(DateTime month) async {
    final currentState = state;
    if (currentState is! SalaryLoaded) {
      await loadSalaries(month: month);
      return;
    }

    try {
      final monthStr =
          '${month.year}-${month.month.toString().padLeft(2, '0')}';

      // Load all salaries and filter for the specific month
      final allSalaries = await _salaryService.getSalaries();
      final salary = allSalaries.where((s) => s.month == monthStr).toList();

      if (salary.isNotEmpty) {
        final updatedSalaries = List<SalaryModel>.from(currentState.salaries);
        final index = updatedSalaries.indexWhere((s) => s.month == monthStr);

        if (index != -1) {
          updatedSalaries[index] = salary.first;
        } else {
          updatedSalaries.add(salary.first);
        }

        final currentMonthStr =
            '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
        final newCurrentSalary = monthStr == currentMonthStr
            ? salary.first
            : currentState.currentSalary;

        emit(currentState.copyWith(
          salaries: updatedSalaries,
          currentSalary: newCurrentSalary,
          selectedMonth: month,
        ));
      } else {
        emit(currentState.copyWith(selectedMonth: month));
      }
    } catch (e) {
      emit(SalaryError(
        message: 'Failed to load salary for month: ${e.toString()}',
        previousState: currentState,
      ));
    }
  }

  // Set selected month
  void setSelectedMonth(DateTime month) {
    final currentState = state;
    if (currentState is SalaryLoaded) {
      emit(currentState.copyWith(selectedMonth: month));
      loadSalaryForMonth(month);
    }
  }

  // Select month and filter salaries
  void selectMonth(String monthStr) {
    final currentState = state;
    if (currentState is! SalaryLoaded) return;

    try {
      // Parse the month string (assuming format like "2024-05")
      final parts = monthStr.split('-');
      if (parts.length != 2) return;

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final selectedMonth = DateTime(year, month);

      // Filter salaries for the selected month
      final filteredSalaries = currentState.salaries
          .where((salary) => salary.month == monthStr)
          .toList();

      emit(currentState.copyWith(
        selectedMonth: selectedMonth,
        filteredSalaries: filteredSalaries,
      ));
    } catch (e) {
      emit(SalaryError(
        message: 'Invalid month format: $monthStr',
        previousState: currentState,
      ));
    }
  }

  // Request salary payment
  Future<void> requestSalaryPayment(int salaryId, {String? notes}) async {
    final currentState = state;
    if (currentState is! SalaryLoaded) return;

    emit(SalaryPaymentRequesting(currentState));

    try {
      final success = await _salaryService.requestSalaryPayment(
        salaryId: salaryId,
        notes: notes,
      );

      if (success) {
        // Update the salary status locally
        final updatedSalaries = currentState.salaries.map((salary) {
          if (salary.id == salaryId) {
            return SalaryModel(
              id: salary.id,
              baseSalary: salary.baseSalary,
              bonus: salary.bonus,
              deductions: salary.deductions,
              totalSalary: salary.totalSalary,
              status: 'processing', // Update status
              month: salary.month,
              paymentDate: salary.paymentDate,
              notes: salary.notes,
              createdAt: salary.createdAt,
              updatedAt: DateTime.now(),
            );
          }
          return salary;
        }).toList();

        final updatedCurrentSalary = currentState.currentSalary?.id == salaryId
            ? updatedSalaries.firstWhere((s) => s.id == salaryId)
            : currentState.currentSalary;

        emit(SalaryPaymentRequested(
          currentState.copyWith(
            salaries: updatedSalaries,
            currentSalary: updatedCurrentSalary,
          ),
        ));
      } else {
        emit(SalaryError(
          message: 'Failed to request salary payment',
          previousState: currentState,
        ));
      }
    } catch (e) {
      emit(SalaryError(
        message: 'Error requesting salary payment: ${e.toString()}',
        previousState: currentState,
      ));
    }
  }

  // Request payment for a salary
  Future<void> requestPayment(int salaryId) async {
    await requestSalaryPayment(salaryId);
  }

  // Submit salary modification request
  Future<void> submitSalaryModificationRequest({
    required String month,
    required double baseSalary,
    required double bonus,
    required double deductions,
    required String reason,
  }) async {
    final currentState = state;
    if (currentState is! SalaryLoaded) return;

    emit(SalaryUpdating(currentState));

    try {
      final success = await _salaryService.submitSalaryModificationRequest(
        month: month,
        baseSalary: baseSalary,
        bonus: bonus,
        deductions: deductions,
        reason: reason,
      );

      if (success) {
        // Reload salaries to get updated data
        await loadSalaries(month: currentState.selectedMonth);
      } else {
        emit(SalaryError(
          message: 'Failed to submit modification request',
          previousState: currentState,
        ));
      }
    } catch (e) {
      emit(SalaryError(
        message: 'Error submitting modification request: ${e.toString()}',
        previousState: currentState,
      ));
    }
  }

  // Update salary (for admin use)
  Future<void> updateSalary({
    required int salaryId,
    required double baseSalary,
    required double bonus,
    required double deductions,
    required String month,
    String? notes,
  }) async {
    final currentState = state;
    if (currentState is! SalaryLoaded) return;

    emit(SalaryUpdating(currentState));

    try {
      final salaryRequest = SalaryRequestModel(
        baseSalary: baseSalary,
        bonus: bonus,
        deductions: deductions,
        month: month,
        notes: notes,
      );

      final updatedSalary = await _salaryService.updateSalary(
        salaryId: salaryId,
        salaryRequest: salaryRequest,
      );

      if (updatedSalary != null) {
        final updatedSalaries = currentState.salaries.map((salary) {
          return salary.id == salaryId ? updatedSalary : salary;
        }).toList();

        final updatedCurrentSalary = currentState.currentSalary?.id == salaryId
            ? updatedSalary
            : currentState.currentSalary;

        emit(currentState.copyWith(
          salaries: updatedSalaries,
          currentSalary: updatedCurrentSalary,
        ));
      } else {
        emit(SalaryError(
          message: 'Failed to update salary',
          previousState: currentState,
        ));
      }
    } catch (e) {
      emit(SalaryError(
        message: 'Error updating salary: ${e.toString()}',
        previousState: currentState,
      ));
    }
  }

  // Retry after error
  Future<void> retry() async {
    final currentState = state;
    if (currentState is SalaryError && currentState.previousState != null) {
      emit(currentState.previousState!);
    } else {
      await loadSalaries();
    }
  }

  // Clear error and return to previous state
  void clearError() {
    final currentState = state;
    if (currentState is SalaryError && currentState.previousState != null) {
      emit(currentState.previousState!);
    }
  }
}
