import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/recommendations_screen.dart';
import 'screens/profile_screen.dart';
import 'services/auth_service.dart';
import 'services/local_storage_service.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Forcer l'orientation portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialiser le service de stockage local
  final storageService = LocalStorageService();
  await storageService.initialize();
  
  // Vérifier le thème préféré
  final isDarkMode = await storageService.getDarkModePreference();
  
  runApp(MyApp(
    storageService: storageService,
    initialThemeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
  ));
}

class MyApp extends StatefulWidget {
  final LocalStorageService storageService;
  final ThemeMode initialThemeMode;
  
  const MyApp({
    super.key,
    required this.storageService,
    this.initialThemeMode = ThemeMode.system, // Ajout d'une valeur par défaut
  });


  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
    _authService = AuthService(widget.storageService);
    _authService.initialize();
    
    // Écouter les changements de thème
    widget.storageService.getUserPreferences().then((prefs) {
      setState(() {
        _themeMode = prefs.darkMode ? ThemeMode.dark : ThemeMode.light;
      });
    });
  }

  void _updateThemeMode(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authService),
        Provider.value(value: widget.storageService),
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
            initialRoute: '/',
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const FavoritesScreen(),
    const RecommendationsScreen(),
    const ProfileScreenAlt(),
  ];
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            // Animation lors du changement d'onglet
            if (index != _currentIndex) {
              _animationController.forward(from: 0.0).then((_) {
                setState(() {
                  _currentIndex = index;
                  _pageController.jumpToPage(index);
                });
              });
            }
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favoris',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.recommend),
              label: 'Pour vous',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}