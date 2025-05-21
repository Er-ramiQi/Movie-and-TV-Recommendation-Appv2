import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'routes.dart';
import 'screens/splash_screen.dart';
import 'services/firebase_auth_service.dart';
import 'services/secure_storage_service.dart';
import 'utils/constants.dart';
import 'utils/security_logger.dart';
import 'utils/api_key_manager.dart';
import 'firebase_options.dart'; // Ce fichier sera généré par FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialiser le logger sécurisé
  await SecurityLogger.initialize();
  
  // Forcer l'orientation portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configurer un gestionnaire d'erreurs global
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    SecurityLogger.error('FlutterError: ${details.exception}', details.exception, details.stack);
  };
  
  // Initialiser le service de stockage sécurisé
  final storageService = SecureStorageService();
  
  // Initialiser la clé API
  await ApiKeyManager.initializeApiKey();
  
  // Vérifier le thème préféré
  final isDarkMode = await storageService.getUserPreferences()
    .then((prefs) => prefs.darkMode);
  
  runApp(MyApp(
    storageService: storageService,
    initialThemeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
  ));
}

class MyApp extends StatefulWidget {
  final SecureStorageService storageService;
  final ThemeMode initialThemeMode;
  
  const MyApp({
    super.key,
    required this.storageService,
    this.initialThemeMode = ThemeMode.system,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late ThemeMode _themeMode;
  late FirebaseAuthService _authService;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
    _authService = FirebaseAuthService();
    
    // Observer le cycle de vie de l'application pour la sécurité
    WidgetsBinding.instance.addObserver(this);
    
    // Écouter les changements de thème
    widget.storageService.getUserPreferences().then((prefs) {
      setState(() {
        _themeMode = prefs.darkMode ? ThemeMode.dark : ThemeMode.light;
      });
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  // Gérer les changements d'état de l'application (premier plan, arrière-plan)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.paused) {
      // L'application est en arrière-plan
      SecurityLogger.info('App moved to background');
    } else if (state == AppLifecycleState.resumed) {
      // L'application est revenue au premier plan
      SecurityLogger.info('App resumed from background');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FirebaseAuthService>.value(value: _authService),
        Provider<SecureStorageService>.value(value: widget.storageService),
        StreamProvider<bool>(
          create: (_) => Stream.periodic(
            const Duration(seconds: 1),
            (_) => _themeMode == ThemeMode.dark,
          ),
          initialData: _themeMode == ThemeMode.dark,
          updateShouldNotify: (_, __) => true,
        ),
      ],
      child: Consumer<bool>(
        builder: (context, isDark, _) {
          widget.storageService.setDarkModePreference(isDark);
          return MaterialApp(
            title: AppConstants.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            onGenerateRoute: AppRoutes.generateRoute,
            navigatorObservers: [
              // Observer pour la journalisation sécurisée de la navigation
              _SecureRouteObserver(),
            ],
            home: const SplashScreen(), // Commencer par l'écran de démarrage
          );
        },
      ),
    );
  }
}

// Observer personnalisé pour la navigation
class _SecureRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    SecurityLogger.debug('Navigation: didPush ${route.settings.name}');
  }
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    SecurityLogger.debug('Navigation: didPop ${route.settings.name}');
  }
}