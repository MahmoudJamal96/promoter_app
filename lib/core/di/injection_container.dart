import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:promoter_app/core/auth/auth_manager.dart';
import 'package:promoter_app/core/network/api_client.dart';
import 'package:promoter_app/core/network/network_info.dart';
import 'package:promoter_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:promoter_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:promoter_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:promoter_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:promoter_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:promoter_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:promoter_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:promoter_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:promoter_app/features/client/data/datasources/client_remote_data_source.dart';
import 'package:promoter_app/features/client/data/repositories/client_repository_impl.dart';
import 'package:promoter_app/features/client/domain/repositories/client_repository.dart';
import 'package:promoter_app/features/client/domain/usecases/get_clients_usecase.dart';
import 'package:promoter_app/features/client/presentation/bloc/client_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Feature service imports
import 'package:promoter_app/features/sales_invoice/services/sales_invoice_service.dart';
import 'package:promoter_app/features/collection/services/collection_service.dart';
import 'package:promoter_app/features/expense/services/expense_service.dart';
import 'package:promoter_app/features/treasury/services/treasury_service.dart';
import 'package:promoter_app/features/returns/services/returns_service.dart';
import 'package:promoter_app/features/products/services/products_service.dart';
import 'package:promoter_app/features/inventory_transfer/services/inventory_transfer_service.dart';

// Feature controllers imports
import 'package:promoter_app/features/sales_invoice/controllers/sales_invoice_controller.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUsecase: sl(),
      logoutUsecase: sl(),
      getCurrentUserUsecase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUsecase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUsecase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Features - Client
  // Bloc
  sl.registerFactory(
    () => ClientBloc(
      getClientsUsecase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetClientsUsecase(sl()));

  // Repository
  sl.registerLazySingleton<ClientRepository>(
    () => ClientRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ClientRemoteDataSource>(
    () => ClientRemoteDataSourceImpl(client: sl()),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Logger
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
  sl.registerLazySingleton(() => logger); // Api Client
  final dio = Dio();
  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ),
  );
  sl.registerLazySingleton(() => dio);
  sl.registerLazySingleton(() => ApiClient(dio: sl(), logger: sl()));

  // Register LoggerCubit for global access
  sl.registerLazySingleton(() => sl<ApiClient>().loggerCubit);

  // Register AuthManager for token restoration on startup
  sl.registerLazySingleton(
    () => AuthManager(
      localDataSource: sl(),
      apiClient: sl(),
    ),
  );

  // Initialize auth state
  await sl<AuthManager>().initializeAuth();

  // Register all feature services
  _registerFeatureServices();
}

void _registerFeatureServices() {
  // Import statements should be added at the top of the file
  // Register Sales Invoice Service
  sl.registerLazySingleton(
    () => SalesInvoiceService(apiClient: sl()),
  );

  // Register Collection Service
  sl.registerLazySingleton(
    () => CollectionService(apiClient: sl()),
  );

  // Register Expense Service
  sl.registerLazySingleton(
    () => ExpenseService(apiClient: sl()),
  );

  // Register Treasury Service
  sl.registerLazySingleton(
    () => TreasuryService(apiClient: sl()),
  );

  // Register Returns Service
  sl.registerLazySingleton(
    () => ReturnsService(apiClient: sl()),
  );

  // Register Products Service
  sl.registerLazySingleton(
    () => ProductsService(apiClient: sl()),
  );

  // Register Inventory Transfer Service
  sl.registerLazySingleton(
    () => InventoryTransferService(apiClient: sl()),
  );

  // Register Controllers
  _registerControllers();
}

void _registerControllers() {
  // Register Sales Invoice Controller
  sl.registerLazySingleton(
    () => SalesInvoiceController(salesInvoiceService: sl()),
  );
}
