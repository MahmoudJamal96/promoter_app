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
import 'package:promoter_app/features/client/cubit/client_cubit_service.dart';
import 'package:promoter_app/features/client/data/datasources/client_remote_data_source.dart';
import 'package:promoter_app/features/client/data/repositories/client_repository_impl.dart';
import 'package:promoter_app/features/client/domain/repositories/client_repository.dart';
import 'package:promoter_app/features/client/domain/usecases/get_clients_usecase.dart';
import 'package:promoter_app/features/client/domain/usecases/update_client_status_usecase.dart';
import 'package:promoter_app/features/client/domain/usecases/create_client_usecase.dart';
import 'package:promoter_app/features/client/presentation/bloc/client_bloc.dart';
import 'package:promoter_app/features/collection/cubit/collection_cubit.dart'; // Added import
import 'package:shared_preferences/shared_preferences.dart';

// Feature service imports
import 'package:promoter_app/features/dashboard/services/dashboard_service.dart';
import 'package:promoter_app/features/dashboard/controllers/dashboard_controller.dart';
import 'package:promoter_app/features/client/services/client_service.dart';
import 'package:promoter_app/features/sales_invoice/services/sales_invoice_service.dart';
import 'package:promoter_app/features/collection/services/collection_service.dart';
import 'package:promoter_app/features/expense/services/expense_service.dart';
import 'package:promoter_app/features/treasury/services/treasury_service.dart';
import 'package:promoter_app/features/returns/services/returns_service.dart';
import 'package:promoter_app/features/products/services/products_service.dart';
import 'package:promoter_app/features/inventory_transfer/services/inventory_transfer_service.dart';
import 'package:promoter_app/features/menu/leave_request/services/leave_request_service.dart';
import 'package:promoter_app/features/menu/leave_request/controllers/leave_request_controller.dart';
import 'package:promoter_app/features/menu/delivery/services/delivery_service.dart';
import 'package:promoter_app/features/menu/messages/services/notification_service.dart';
import 'package:promoter_app/features/salary/services/salary_service.dart';
import 'package:promoter_app/features/salary/cubit/salary_cubit.dart';

// Feature controllers imports
import 'package:promoter_app/features/sales_invoice/controllers/sales_invoice_controller.dart';

import '../../features/menu/leave_request/di/leave_request_di.dart';

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
      networkInfo: sl(),
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  ); // Features - Client
  // Bloc/Cubit
  sl.registerFactory(
    () => ClientCubit(sl()),
  );

  // registerLeaveRequestDependencies();
  // Use cases
  sl.registerLazySingleton(() => GetClientsUsecase(sl()));
  sl.registerLazySingleton(() => UpdateClientStatusUsecase(sl()));
  sl.registerLazySingleton(() => CreateClientUsecase(sl()));

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
  // Register Dashboard Service
  sl.registerLazySingleton(
    () => DashboardService(apiClient: sl()),
  );

  // Register Dashboard Controller
  sl.registerLazySingleton(
    () => DashboardController(dashboardService: sl()),
  );

  // Register Client Service
  sl.registerLazySingleton(
    () => ClientService(apiClient: sl()),
  );

  // Register Sales Invoice Service
  sl.registerLazySingleton(
    () => SalesInvoiceService(apiClient: sl()),
  );

  // Register Leave Request Service
  sl.registerLazySingleton(
    () => LeaveRequestService(apiClient: sl()),
  );

  // Register Leave Request Controller
  sl.registerLazySingleton(
    () => LeaveRequestController(leaveRequestService: sl()),
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

  // Register Delivery Service
  sl.registerLazySingleton(
    () => DeliveryService(apiClient: sl()),
  );

  // Register Notification Service
  sl.registerLazySingleton(
    () => NotificationService(apiClient: sl()),
  );

  // Register Salary Service
  sl.registerLazySingleton(
    () => SalaryService(apiClient: sl()),
  );

  // Register Cubits
  _registerCubits(); // Added call to register cubits

  // Register Controllers
  _registerControllers();
}

// Added method to register cubits
void _registerCubits() {
  sl.registerFactory(
    () => CollectionCubit(
        collectionService: sl<CollectionService>()), // Corrected argument
  );

  // Register Salary Cubit
  sl.registerFactory(
    () => SalaryCubit(salaryService: sl<SalaryService>()),
  );
}

void _registerControllers() {
  // Register Sales Invoice Controller
  sl.registerLazySingleton(
    () => SalesInvoiceController(salesInvoiceService: sl()),
  );
}
