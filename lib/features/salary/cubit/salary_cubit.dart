import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../models/salary_model.dart';
import '../services/salary_service.dart';
import 'salary_state.dart';

class SalaryCubit extends Cubit<SalaryState> {
  final SalaryService _salaryService;

  SalaryCubit({SalaryService? salaryService})
      : _salaryService = salaryService ?? sl(),
        super(SalaryState.initial());

  /// Load salaries for the current month
  Future<void> loadSalaries() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final salaries = await _salaryService.getSalaries();
      // Filter salaries for the selected month
      final filteredSalaries =
          _filterSalariesByMonth(salaries, state.selectedMonth);
      final stats = SalaryStatsModel.fromSalaries(filteredSalaries);

      emit(state.copyWith(
        isLoading: false,
        salaries: filteredSalaries,
        stats: stats,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'حدث خطأ أثناء تحميل البيانات: ${e.toString()}',
      ));
    }
  }

  /// Filter salaries by month
  List<SalaryModel> _filterSalariesByMonth(
      List<SalaryModel> salaries, int month) {
    return salaries.where((salary) {
      // Convert month int to string for comparison (e.g., 5 -> "5" or "05")
      final monthStr = month.toString();
      final paddedMonthStr = month.toString().padLeft(2, '0');
      return salary.month.endsWith(monthStr) ||
          salary.month.endsWith(paddedMonthStr);
    }).toList();
  }

  /// Change selected month and reload data
  Future<void> changeMonth(int month) async {
    emit(state.copyWith(selectedMonth: month));
    await loadSalaries();
  }

  /// Add new salary entry
  Future<void> addSalary(SalaryRequestModel request) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final newSalary = await _salaryService.createSalary(request);
      if (newSalary != null) {
        // Reload salaries to get updated list
        await loadSalaries();
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'فشل في إضافة الراتب',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'حدث خطأ أثناء إضافة الراتب: ${e.toString()}',
      ));
    }
  }

  /// Add new individual salary entry
  Future<void> addSalaryEntry(EntryRequestModel request) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final success = await _salaryService.createSalaryEntry(request);
      if (success) {
        // Reload salaries to get updated list with new entry aggregated
        await loadSalaries();
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'فشل في إضافة الراتب',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'حدث خطأ أثناء إضافة الراتب: ${e.toString()}',
      ));
    }
  }

  /// Update salary entry
  Future<void> updateSalary(String id, SalaryRequestModel request) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final updatedSalary = await _salaryService.updateSalary(
        salaryId: int.parse(id),
        salaryRequest: request,
      );
      if (updatedSalary != null) {
        // Reload salaries to get updated list
        await loadSalaries();
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'فشل في تحديث الراتب',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'حدث خطأ أثناء تحديث الراتب: ${e.toString()}',
      ));
    }
  }

  /// Delete salary entry
  Future<void> deleteSalary(String id) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final success = await _salaryService.deleteSalary(id);
      if (success) {
        // Reload salaries to get updated list
        await loadSalaries();
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'فشل في حذف الراتب',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'حدث خطأ أثناء حذف الراتب: ${e.toString()}',
      ));
    }
  }

  /// Get month name in Arabic
  String getMonthName(int month) {
    const monthNames = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return monthNames[month - 1];
  }
}
