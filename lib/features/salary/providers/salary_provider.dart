import 'package:flutter/material.dart';
import '../models/salary_model.dart';
import '../services/salary_service.dart';

class SalaryProvider extends ChangeNotifier {
  final SalaryService _salaryService;

  SalaryProvider({SalaryService? salaryService})
      : _salaryService = salaryService ?? SalaryService();

  // State variables
  List<SalaryModel> _salaries = [];
  SalaryModel? _currentSalary;
  SalaryStatsModel? _salaryStats;
  Map<String, dynamic>? _userInfo;
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;
  DateTime _selectedMonth = DateTime.now();

  // Getters
  List<SalaryModel> get salaries => _salaries;
  SalaryModel? get currentSalary => _currentSalary;
  SalaryStatsModel? get salaryStats => _salaryStats;
  Map<String, dynamic>? get userInfo => _userInfo;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;
  DateTime get selectedMonth => _selectedMonth;

  // Get current month salary
  SalaryModel? get currentMonthSalary {
    final currentMonthStr =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    return _salaries.firstWhere(
      (salary) => salary.month == currentMonthStr,
      orElse: () => _salaries.isNotEmpty
          ? _salaries.first
          : SalaryModel(
              id: 0,
              baseSalary: 0,
              bonus: 0,
              deductions: 0,
              totalSalary: 0,
              status: 'pending',
              month: currentMonthStr,
            ),
    );
  }

  // Get salary history (excluding current month)
  List<SalaryModel> get salaryHistory {
    final currentMonthStr =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    return _salaries.where((salary) => salary.month != currentMonthStr).toList()
      ..sort((a, b) => b.month.compareTo(a.month)); // Sort by month descending
  }

  // Set selected month
  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    notifyListeners();
    _loadSalaryForMonth(month);
  }

  // Initialize data
  Future<void> initialize() async {
    await loadSalaries();
    await loadUserInfo();
    await loadSalaryStats();
  }

  // Load all salaries
  Future<void> loadSalaries() async {
    _setLoading(true);
    _clearError();

    try {
      _salaries = await _salaryService.getSalaries();

      // Set current salary if available
      final currentMonthStr =
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
      _currentSalary = _salaries.firstWhere(
        (salary) => salary.month == currentMonthStr,
        orElse: () => null,
      );
    } catch (e) {
      _setError('Failed to load salaries: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load salary for specific month
  Future<void> _loadSalaryForMonth(DateTime month) async {
    final monthStr = '${month.year}-${month.month.toString().padLeft(2, '0')}';

    try {
      final salary = await _salaryService.getSalaryByMonth(monthStr);
      if (salary != null) {
        // Update the salary in the list if it exists
        final index = _salaries.indexWhere((s) => s.month == monthStr);
        if (index != -1) {
          _salaries[index] = salary;
        } else {
          _salaries.add(salary);
        }

        if (monthStr ==
            '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}') {
          _currentSalary = salary;
        }

        notifyListeners();
      }
    } catch (e) {
      print('Error loading salary for month $monthStr: $e');
    }
  }

  // Load user info
  Future<void> loadUserInfo() async {
    try {
      _userInfo = await _salaryService.getUserInfo();
      notifyListeners();
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  // Load salary statistics
  Future<void> loadSalaryStats() async {
    try {
      _salaryStats = await _salaryService.getSalaryStats();
      notifyListeners();
    } catch (e) {
      print('Error loading salary stats: $e');
    }
  }

  // Request salary payment
  Future<bool> requestSalaryPayment(int salaryId, {String? notes}) async {
    _setUpdating(true);
    _clearError();

    try {
      final success = await _salaryService.requestSalaryPayment(
        salaryId: salaryId,
        notes: notes,
      );

      if (success) {
        // Update the salary status locally
        final index = _salaries.indexWhere((s) => s.id == salaryId);
        if (index != -1) {
          _salaries[index] = _salaries[index].copyWith(status: 'processing');

          if (_currentSalary?.id == salaryId) {
            _currentSalary = _currentSalary!.copyWith(status: 'processing');
          }

          notifyListeners();
        }
      }

      return success;
    } catch (e) {
      _setError('Failed to request salary payment: ${e.toString()}');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Submit salary modification request
  Future<bool> submitSalaryModificationRequest({
    required String month,
    required double baseSalary,
    required double bonus,
    required double deductions,
    required String reason,
  }) async {
    _setUpdating(true);
    _clearError();

    try {
      final success = await _salaryService.submitSalaryModificationRequest(
        month: month,
        baseSalary: baseSalary,
        bonus: bonus,
        deductions: deductions,
        reason: reason,
      );

      return success;
    } catch (e) {
      _setError('Failed to submit modification request: ${e.toString()}');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Update salary (for admin use)
  Future<bool> updateSalary({
    required int salaryId,
    required double baseSalary,
    required double bonus,
    required double deductions,
    required String month,
    String? notes,
  }) async {
    _setUpdating(true);
    _clearError();

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
        // Update the salary in the list
        final index = _salaries.indexWhere((s) => s.id == salaryId);
        if (index != -1) {
          _salaries[index] = updatedSalary;

          if (_currentSalary?.id == salaryId) {
            _currentSalary = updatedSalary;
          }

          notifyListeners();
        }
        return true;
      }

      return false;
    } catch (e) {
      _setError('Failed to update salary: ${e.toString()}');
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Calculate total salary
  double calculateTotalSalary(
      double baseSalary, double bonus, double deductions) {
    return baseSalary + bonus - deductions;
  }

  // Get salary by month
  SalaryModel? getSalaryByMonth(String month) {
    try {
      return _salaries.firstWhere((salary) => salary.month == month);
    } catch (e) {
      return null;
    }
  }

  // Refresh all data
  Future<void> refresh() async {
    await loadSalaries();
    await loadSalaryStats();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setUpdating(bool updating) {
    _isUpdating = updating;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
