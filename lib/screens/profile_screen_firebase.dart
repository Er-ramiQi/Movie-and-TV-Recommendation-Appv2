import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firebase_auth_service.dart';
import '../services/image_service.dart';
import '../services/secure_storage_service.dart';
import '../utils/constants.dart';
import '../utils/security_logger.dart';
import 'auth/login_screen.dart';

class ProfileScreenFirebase extends StatefulWidget {
  const ProfileScreenFirebase({super.key});

  @override
  State<ProfileScreenFirebase> createState() => _ProfileScreenFirebaseState();
}

class _ProfileScreenFirebaseState extends State<ProfileScreenFirebase> with SingleTickerProviderStateMixin {
  late FirebaseAuthService _authService;
  late SecureStorageService _storageService;
  late ImageService _imageService;
  bool _isLoading = false;
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
  List<String> _selectedGenres = [];

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<FirebaseAuthService>(context, listen: false);
    _storageService = Provider.of<SecureStorageService>(context, listen: false);
    _imageService = ImageService();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await _storageService.getUserPreferences();
      
      setState(() {
        _selectedGenres = prefs.preferredGenres;
        _isLoading = false;
      });
    } catch (e) {
      SecurityLogger.error('Error loading user preferences: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
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
    final userProfile = _authService.userProfile;
    if (userProfile == null) return;
    
    setState(() {
      _isEditing = true;
      _usernameController.text = userProfile.username;
      _bioController.text = userProfile.bio ?? '';
    });
  }

  Future<void> _saveProfile() async {
    final userProfile = _authService.userProfile;
    if (userProfile == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _authService.updateProfile(
        username: _usernameController.text,
        bio: _bioController.text,
      );

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil mis à jour avec succès'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_authService.errorMessage ?? AppConstants.genericErrorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      SecurityLogger.error('Error saving profile: ${e.toString()}');
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

  Future<void> _pickProfileImage() async {
    final userProfile = _authService.userProfile;
    if (userProfile == null) return;
    
    try {
      final imagePath = await _imageService.pickAndSaveImage(source: ImageSource.gallery);
      
      if (imagePath != null && mounted) {
        setState(() {
          _isLoading = true;
        });
        
        // Dans une vraie application, vous téléchargeriez l'image sur Firebase Storage
        // ici, nous allons simplement mettre à jour l'URL
        
        final success = await _authService.updateProfile(
          avatarUrl: imagePath,
        );
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photo de profil mise à jour avec succès'),
                backgroundColor: AppColors.success,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_authService.errorMessage ?? 'Erreur lors de la mise à jour de la photo de profil'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      SecurityLogger.error('Error picking profile image: ${e.toString()}');
    }
  }

  Future<void> _toggleDarkMode(bool value) async {
    await _storageService.setDarkModePreference(value);
  }

  Future<void> _updateGenrePreferences(List<String> genres) async {
    try {
      await _storageService.updatePreferredGenres(genres);
      setState(() {
        _selectedGenres = genres;
      });
    } catch (e) {
      SecurityLogger.error('Error updating genre preferences: ${e.toString()}');
    }
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
                
                // Rediriger vers la page de connexion
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
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
    final userProfile = _authService.userProfile;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    if (userProfile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : _isEditing
              ? _buildEditProfileForm(userProfile)
              : _buildProfileContent(userProfile, isDarkMode),
    );
  }

  Widget _buildProfileContent(dynamic userProfile, bool isDarkMode) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return SafeArea(
      child: Column(
        children: [
          // En-tête de profil moderne
          _buildProfileHeader(userProfile, isDarkMode),
          
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
                _buildProfileTab(userProfile, isSmallScreen),
                
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

  // En-tête de profil avec avatar
  Widget _buildProfileHeader(dynamic userProfile, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
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
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickProfileImage,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: userProfile.avatarUrl != null
                        ? Image(
                            image: _imageService.getProfileImageProvider(userProfile.avatarUrl),
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                          )
                        : Container(
                            color: AppColors.primaryDark,
                            child: Center(
                              child: Text(
                                userProfile.username.isNotEmpty
                                    ? userProfile.username[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userProfile.username,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userProfile.email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          if (userProfile.bio != null && userProfile.bio.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                userProfile.bio,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Onglet Profil
  Widget _buildProfileTab(dynamic userProfile, bool isSmallScreen) {
    const int moviesCount = 0; // À récupérer depuis Firestore
    const int showsCount = 0; // À récupérer depuis Firestore
    
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
                        value: '${_selectedGenres.length}',
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
                    value: userProfile.username,
                  ),
                  _buildInfoItem(
                    icon: Icons.email,
                    label: 'Email',
                    value: userProfile.email,
                  ),
                  _buildInfoItem(
                    icon: Icons.calendar_today,
                    label: 'Compte créé le',
                    value: _formatDate(userProfile.createdAt),
                  ),
                  if (userProfile.bio != null && userProfile.bio.isNotEmpty)
                    _buildInfoItem(
                      icon: Icons.info_outline,
                      label: 'Bio',
                      value: userProfile.bio,
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
                      final isSelected = _selectedGenres.contains(genre);
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
    return Consumer<bool>(
      builder: (context, isDark, _) {
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
                        value: isDark,
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
      },
    );
  }

  // Formulaire d'édition du profil
  Widget _buildEditProfileForm(dynamic userProfile) {
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
            
            // Avatar
            Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  children: [
                    Container(
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
                      child: ClipOval(
                        child: userProfile.avatarUrl != null
                            ? Image(
                                image: _imageService.getProfileImageProvider(userProfile.avatarUrl),
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              )
                            : Center(
                                child: Text(
                                  userProfile.username.isNotEmpty
                                      ? userProfile.username[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
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
        List<String> updatedGenres = List.from(_selectedGenres);
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