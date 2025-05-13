import 'package:promoter_app/qara_ksa.dart';

import '../../utils/nullable.dart';
import '../data/model/loggers_base.dart';
import '../data/profile_api.dart';
import '../data/repo/loggers_repo.dart';

part 'loggers_state.dart';

class LoggersCubit extends Cubit<LoggersState> {
  final LoggersRepo _loggersRepo;

  LoggersCubit(this._loggersRepo) : super(LoggersStateInitial());

  Future<void> log({
    required LoggersBase loggerResponseModel,
    required ProfileApi profile,
    Map<String, dynamic>? query,
    Map<String, dynamic>? mockResponse,
  }) async {
    emit(state.requestLoading());
    final result = await _loggersRepo.log(loggerResponseModel, profile,
        query: query, mockResponse: mockResponse);
    emit(
      result.fold(
        (l) => state.requestFailed(l),
        (r) => state.requestSuccess(r),
      ),
    );
  }

  Future<Either<Failure, LoggersBase>> logForResult({
    required LoggersBase loggerResponseModel,
    required ProfileApi profile,
    Map<String, dynamic>? query,
    Map<String, dynamic>? mockResponse,
  }) async {
    emit(state.requestLoading());
    final result = await _loggersRepo.log(loggerResponseModel, profile,
        query: query, mockResponse: mockResponse);
    // LoggersBase? data = null;
    // emit(result.fold(
    //   (l) {
    //     return state.requestFailed(l);
    //   },
    //   (r) {
    //     data = r;
    //     return state.requestSuccess(r);
    //   },
    // ));

    return result;
  }

  Future<void> post({
    required LoggersBase loggerResponseModel,
    required ProfileApi profile,
    required RequestModel requestModel,
    Map<String, dynamic>? query,
    Map<String, dynamic>? mockResponse,
  }) async {
    emit(state.requestLoading());
    final result = await _loggersRepo.post(loggerResponseModel,
        requestModel: requestModel,
        profile, query: query, mockResponse: mockResponse);
    emit(
      result.fold(
            (l) => state.requestFailed(l),
            (r) => state.requestSuccess(r),
      ),
    );
  }

  void requestFailed(Failure failure) {
    emit(state.requestFailed(failure));
  }
}

