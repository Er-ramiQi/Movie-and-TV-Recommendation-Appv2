import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../models/user_preferences.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../utils/constants.dart';

class ProfileScreenAlt extends StatefulWidget {
  const ProfileScreenAlt({super.key});

  @override
  State<ProfileScreenAlt> createState() => _ProfileScreenAltState();
}

class _ProfileScreenAltState extends State<ProfileScreenAlt> with SingleTickerProviderStateMixin {
  late AuthService _authService;
  late LocalStorageService _storageService;
  UserPreferences? _userPreferences;
  bool _isLoading = true;
  bool _isEditing = false;
  late TabController _tabController;
  
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  final List<String> _availableGenres = [
    'Action', 'Aventure', 'Animation', 'Comédie', 'Crime',
    'Documentaire', 'Drame', 'Famille', 'Fantastique', 'Histoire',
    'Horreur', 'Musique', 'Mystère', 'Romance', 'Science-Fiction',
    'Thriller', 'Guerre', 'Western'
  ];

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    _storageService = Provider.of<LocalStorageService>(context, listen: false);
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await _storageService.getUserPreferences();

      if (mounted) {
        setState(() {
          _userPreferences = prefs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.genericErrorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _startEditing() {
    final user = _authService.currentUser;
    if (user == null) return;
    
    setState(() {
      _isEditing = true;
      _usernameController.text = user.username;
      _bioController.text = user.bio ?? '';
    });
  }

  Future<void> _saveProfile() async {
    final user = _authService.currentUser;
    if (user == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _authService.updateProfile(
        username: _usernameController.text,
        bio: _bioController.text,
      );

      if (mounted) {
        if (success) {
          setState(() {
            _isEditing = false;
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil mis à jour avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppConstants.genericErrorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.genericErrorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleDarkMode(bool value) async {
    if (_userPreferences == null) return;
    
    await _storageService.setDarkModePreference(value);
    await _loadUserData();
  }

  Future<void> _updateGenrePreferences(List<String> genres) async {
    if (_userPreferences == null) return;
    
    await _storageService.updatePreferredGenres(genres);
    await _loadUserData();
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Se déconnecter'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _authService.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Vous n\'êtes pas connecté',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _authService.signIn('user@example.com', 'password'),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : _isEditing
              ? _buildEditProfileForm(user)
              : _buildProfileContent(user, isDarkMode),
    );
  }

  Widget _buildProfileContent(UserProfile user, bool isDarkMode) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return SafeArea(
      child: Column(
        children: [
          // En-tête de profil moderne
          _buildProfileHeader(user, isDarkMode),
          
          // Tabs pour organiser le contenu
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
            tabs: const [
              Tab(text: 'Profil'),
              Tab(text: 'Préférences'),
              Tab(text: 'Paramètres'),
            ],
          ),
          
          // Contenu des tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Onglet 1: Informations du profil
                _buildProfileTab(user, isSmallScreen),
                
                // Onglet 2: Préférences et genres
                _buildPreferencesTab(isSmallScreen),
                
                // Onglet 3: Paramètres
                _buildSettingsTab(isSmallScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // En-tête de profil avec initiales au lieu d'image
  Widget _buildProfileHeader(UserProfile user, bool isDarkMode) {
    final initials = user.username.isNotEmpty 
      ? user.username.substring(0, 1).toUpperCase() 
      : 'U';
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [AppColors.primaryDark, AppColors.primaryLight]
              : [AppColors.primaryLight, AppColors.accent.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          // Avatar circulaire avec initiales
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Informations utilisateur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    user.bio!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Bouton d'édition
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _startEditing,
          ),
        ],
      ),
    );
  }

  // Onglet Profil
  Widget _buildProfileTab(UserProfile user, bool isSmallScreen) {
    final int moviesCount = _userPreferences?.favoriteMovieIds.length ?? 0;
    final int showsCount = _userPreferences?.favoriteTvShowIds.length ?? 0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistiques
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistiques',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: Icons.movie,
                        label: 'Films favoris',
                        value: '$moviesCount',
                        color: AppColors.accent,
                      ),
                      _buildStatItem(
                        icon: Icons.tv,
                        label: 'Séries favorites',
                        value: '$showsCount',
                        color: AppColors.primaryLight,
                      ),
                      _buildStatItem(
                        icon: Icons.category,
                        label: 'Genres préférés',
                        value: '${_userPreferences?.preferredGenres.length ?? 0}',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Informations personnelles
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations personnelles',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem(
                    icon: Icons.person,
                    label: 'Nom d\'utilisateur',
                    value: user.username,
                  ),
                  _buildInfoItem(
                    icon: Icons.email,
                    label: 'Email',
                    value: user.email,
                  ),
                  _buildInfoItem(
                    icon: Icons.calendar_today,
                    label: 'Compte créé le',
                    value: _formatDate(user.createdAt),
                  ),
                  if (user.bio != null && user.bio!.isNotEmpty)
                    _buildInfoItem(
                      icon: Icons.info_outline,
                      label: 'Bio',
                      value: user.bio!,
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Bouton d'édition
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startEditing,
              icon: const Icon(Icons.edit),
              label: const Text('Modifier le profil'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Onglet Préférences
  Widget _buildPreferencesTab(bool isSmallScreen) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Genres préférés
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Genres préférés',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableGenres.map((genre) {
                      final isSelected = 
                          _userPreferences?.preferredGenres.contains(genre) ?? false;
                      return _buildGenreChip(
                        genre: genre,
                        isSelected: isSelected,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recommandations
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recommandations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.movie_filter,
                        color: AppColors.accent,
                      ),
                    ),
                    title: const Text('Voir mes recommandations'),
                    subtitle: const Text('Basées sur vos préférences'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pushNamed(context, '/recommendations');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Onglet Paramètres
  Widget _buildSettingsTab(bool isSmallScreen) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Apparence
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Apparence',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Mode sombre'),
                    subtitle: const Text('Économisez votre batterie'),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.dark_mode,
                        color: AppColors.accent,
                      ),
                    ),
                    value: _userPreferences?.darkMode ?? true,
                    onChanged: _toggleDarkMode,
                    activeColor: AppColors.accent,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Notifications
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Nouvelles recommandations'),
                    subtitle: const Text('Recevez des notifications pour de nouveaux films'),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.notifications,
                        color: AppColors.accent,
                      ),
                    ),
                    value: true,
                    onChanged: (value) {},
                    activeColor: AppColors.accent,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Compte
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Compte',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.exit_to_app,
                        color: AppColors.error,
                      ),
                    ),
                    title: const Text(
                      'Se déconnecter',
                      style: TextStyle(
                        color: AppColors.error,
                      ),
                    ),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Formulaire d'édition du profil
  Widget _buildEditProfileForm(UserProfile user) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                  },
                ),
                const Text(
                  'Modifier le profil',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Avatar avec initiales
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user.username.isNotEmpty 
                        ? user.username.substring(0, 1).toUpperCase() 
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Champ Nom d'utilisateur
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Nom d\'utilisateur',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Champ Bio
            TextField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: 'Bio',
                prefixIcon: const Icon(Icons.info_outline),
                hintText: 'Parlez-nous de vous...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 4,
            ),
            
            const SizedBox(height: 32),
            
            // Bouton Enregistrer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour les items de statistiques
  Widget _buildStatItem({
    required IconData icon, 
    required String label, 
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Widget pour les items d'information
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour les chips de genre
  Widget _buildGenreChip({
    required String genre,
    required bool isSelected,
  }) {
    return FilterChip(
      label: Text(genre),
      selected: isSelected,
      checkmarkColor: Colors.white,
      selectedColor: AppColors.accent,
      backgroundColor: AppColors.primaryLight.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
      ),
      onSelected: (selected) {
        List<String> updatedGenres = List.from(_userPreferences?.preferredGenres ?? []);
        if (selected) {
          updatedGenres.add(genre);
        } else {
          updatedGenres.remove(genre);
        }
        _updateGenrePreferences(updatedGenres);
      },
    );
  }

  // Formatage de date
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    final month = months[date.month - 1];
    return '$day $month ${date.year}';
  }
}