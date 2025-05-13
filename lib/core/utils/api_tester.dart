import 'package:flutter/material.dart';
import 'package:promoter_app/core/network/api_client.dart';
import 'package:promoter_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:promoter_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:promoter_app/features/auth/data/models/token_model.dart';
import 'package:get_it/get_it.dart';

class ApiTester {
  final ApiClient apiClient;
  final AuthRemoteDataSource authRemoteDataSource;
  final AuthLocalDataSource authLocalDataSource;

  ApiTester({
    required this.apiClient,
    required this.authRemoteDataSource,
    required this.authLocalDataSource,
  });

  /// Tests the login API endpoint
  Future<String> testLoginApi(String username, String password) async {
    try {
      // Perform login with the auth remote data source
      final result = await authRemoteDataSource.login(username, password);
      final (user, token) = result;

      // Print test results
      String response = "Login successful!\n";
      response += "User: ${user.name} (${user.email})\n";
      response += "Token: ${token.accessToken.substring(0, 20)}...\n";

      return response;
    } catch (e) {
      return "Login failed: $e";
    }
  }

  /// Tests if a stored token exists
  Future<String> checkStoredToken() async {
    try {
      final token = await authLocalDataSource.getToken();
      if (token != null) {
        return "Stored token found: ${token.accessToken.substring(0, 20)}...";
      } else {
        return "No token stored";
      }
    } catch (e) {
      return "Error checking token: $e";
    }
  }

  /// Tests API connection with a simple endpoint
  Future<String> testApiConnection() async {
    try {
      // Try to get a simple endpoint
      await apiClient.get('/ping');
      return "API connection successful!";
    } catch (e) {
      return "API connection failed: $e";
    }
  }

  /// Tests token storage
  Future<String> testTokenStorage() async {
    try {
      // Create a test token
      final testToken = TokenModel(
          accessToken: "test_token_${DateTime.now().millisecondsSinceEpoch}");

      // Store the token
      await authLocalDataSource.cacheToken(testToken);

      // Retrieve the token
      final retrievedToken = await authLocalDataSource.getToken();

      if (retrievedToken == null) {
        return "Token storage test failed: Retrieved token is null";
      }

      if (retrievedToken.accessToken == testToken.accessToken) {
        return "Token storage test successful!";
      } else {
        return "Token storage test failed: Tokens don't match";
      }
    } catch (e) {
      return "Token storage test failed: $e";
    }
  }
}

class ApiTesterWidget extends StatefulWidget {
  const ApiTesterWidget({Key? key}) : super(key: key);

  @override
  _ApiTesterWidgetState createState() => _ApiTesterWidgetState();
}

class _ApiTesterWidgetState extends State<ApiTesterWidget> {
  final _usernameController = TextEditingController(text: "test_user");
  final _passwordController = TextEditingController(text: "password");
  String _testResult = "No tests run yet";
  bool _isLoading = false;

  late ApiTester _apiTester;

  @override
  void initState() {
    super.initState();
    final sl = GetIt.instance;
    _apiTester = ApiTester(
      apiClient: sl<ApiClient>(),
      authRemoteDataSource: sl<AuthRemoteDataSource>(),
      authLocalDataSource: sl<AuthLocalDataSource>(),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _runLoginTest() async {
    setState(() {
      _isLoading = true;
      _testResult = "Running login test...";
    });

    final result = await _apiTester.testLoginApi(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() {
      _testResult = result;
      _isLoading = false;
    });
  }

  Future<void> _checkStoredToken() async {
    setState(() {
      _isLoading = true;
      _testResult = "Checking stored token...";
    });

    final result = await _apiTester.checkStoredToken();

    setState(() {
      _testResult = result;
      _isLoading = false;
    });
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = "Testing API connection...";
    });

    final result = await _apiTester.testApiConnection();

    setState(() {
      _testResult = result;
      _isLoading = false;
    });
  }

  Future<void> _testTokenStorage() async {
    setState(() {
      _isLoading = true;
      _testResult = "Testing token storage...";
    });

    final result = await _apiTester.testTokenStorage();

    setState(() {
      _testResult = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("API Tester"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _runLoginTest,
                child: const Text("Test Login API"),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _checkStoredToken,
                child: const Text("Check Stored Token"),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _testConnection,
                child: const Text("Test API Connection"),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _testTokenStorage,
                child: const Text("Test Token Storage"),
              ),
              const SizedBox(height: 24),
              const Text(
                "Test Results:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Text(_testResult),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
