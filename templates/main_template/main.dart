import 'app/modules/home/bindings/home_binding.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'app/routes/app_pages.dart';
import 'app/services/storage.dart';
import 'dio_template/endpoints.dart';
import 'dio_template/network_connectivity.dart';

/// Main entry point of the application
/// Handles initialization, error handling, and app configuration
Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error handling
  _initializeErrorHandling();

  try {
    // Initialize services
    await initGetServices();

    // Configure app orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Run the app
    runApp(
      GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: GetMaterialApp(
          // theme: AppTheme.light,
          // darkTheme: AppTheme.dark,
          defaultTransition: Transition.fade,
          transitionDuration: const Duration(milliseconds: 300),
          smartManagement: SmartManagement.full,
          debugShowCheckedModeBanner: false,
          locale: const Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US'),
          // translationsKeys: AppTranslation.translations,
          initialRoute: AppPages.INITIAL,
          initialBinding: HomeBinding(),
          getPages: AppPages.routes,
          // Error handling
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child ?? const SizedBox(),
            );
          },
        ),
      ),
    );
  } catch (e, stackTrace) {
    // Handle initialization errors
    if (kDebugMode) {
      developer.log(
        'App initialization error: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }

    // Run error screen or fallback
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize app',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Initialize error handling for Flutter framework errors
void _initializeErrorHandling() {
  // Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.presentError(details);
      developer.log(
        'Flutter Error: ${details.exception}',
        error: details.exception,
        stackTrace: details.stack,
      );
    } else {
      // In production, log to crash reporting service
      // Example: FirebaseCrashlytics.instance.recordFlutterError(details);
    }
  };

  // Handle platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      developer.log(
        'Platform Error: $error',
        error: error,
        stackTrace: stack,
      );
    }
    return true;
  };
}

/// Initialize GetX services
/// This should be called before running the app
Future<void> initGetServices() async {
  try {
    // Initialize storage service
    await Get.putAsync<GetStorageService>(
      () => GetStorageService().initState(),
      permanent: true,
    );

    // Set API environment based on build mode
    if (kDebugMode) {
      Endpoints.setEnvironment(Environment.development);
    } else {
      // In production, you might want to use environment variables
      Endpoints.setEnvironment(Environment.production);
    }

    // Initialize network connectivity monitoring
    await NetworkConnectivity.instance.initialize();

    // Initialize repositories and data sources
    // Uncomment and configure based on your needs
    // RepositoryLocator.setup();

    if (kDebugMode) {
      developer.log('Services initialized successfully');
      developer.log('API Environment: ${Endpoints.environment}');
      developer.log('API Base URL: ${Endpoints.baseUrl}');
      developer.log('Network Status: ${NetworkConnectivity.instance.isConnected}');
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      developer.log(
        'Error initializing services: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
    rethrow;
  }
}
