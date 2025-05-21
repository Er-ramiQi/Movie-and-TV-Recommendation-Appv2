import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../utils/security_logger.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  authenticating,
  error
}

class FirebaseAuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // État actuel de l'authentification
  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;
  
  // Utilisateur actuel de Firebase
  User? _firebaseUser;
  User? get firebaseUser => _firebaseUser;
  
  // Profil utilisateur custom
  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;
  
  // Message d'erreur
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  // Constructeur
  FirebaseAuthService() {
    // Écouter les changements d'état de l'authentification
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }
  
  // Méthode appelée lorsque l'état d'authentification change
  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _firebaseUser = null;
      _userProfile = null;
    } else {
      _firebaseUser = user;
      _status = AuthStatus.authenticated;
      
      // Charger les données du profil utilisateur depuis Firestore
      await _loadUserProfile();
    }
    
    notifyListeners();
  }
  
  // Charger le profil utilisateur depuis Firestore
  Future<void> _loadUserProfile() async {
    if (_firebaseUser == null) return;
    
    try {
      final doc = await _firestore.collection('users').doc(_firebaseUser!.uid).get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        
        _userProfile = UserProfile(
          id: _firebaseUser!.uid,
          username: data['username'] ?? _firebaseUser!.displayName ?? _firebaseUser!.email!.split('@')[0],
          email: _firebaseUser!.email!,
          avatarUrl: data['avatarUrl'] ?? _firebaseUser!.photoURL,
          bio: data['bio'],
          createdAt: data['createdAt'] != null 
              ? (data['createdAt'] as Timestamp).toDate() 
              : DateTime.now(),
          lastLogin: DateTime.now(),
        );
      } else {
        // Si le document n'existe pas, créer un profil de base
        _userProfile = UserProfile(
          id: _firebaseUser!.uid,
          username: _firebaseUser!.displayName ?? _firebaseUser!.email!.split('@')[0],
          email: _firebaseUser!.email!,
          avatarUrl: _firebaseUser!.photoURL,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );
        
        // Sauvegarder le nouveau profil dans Firestore
        await _saveUserProfile();
      }
    } catch (e) {
      SecurityLogger.error('Error loading user profile: ${e.toString()}');
      _errorMessage = 'Erreur lors du chargement du profil utilisateur.';
    }
  }
  
  // Sauvegarder le profil utilisateur dans Firestore
  Future<bool> _saveUserProfile() async {
    if (_firebaseUser == null || _userProfile == null) return false;
    
    try {
      await _firestore.collection('users').doc(_firebaseUser!.uid).set({
        'username': _userProfile!.username,
        'email': _userProfile!.email,
        'avatarUrl': _userProfile!.avatarUrl,
        'bio': _userProfile!.bio,
        'createdAt': Timestamp.fromDate(_userProfile!.createdAt),
        'lastLogin': Timestamp.fromDate(DateTime.now()),
      }, SetOptions(merge: true));
      
      return true;
    } catch (e) {
      SecurityLogger.error('Error saving user profile: ${e.toString()}');
      _errorMessage = 'Erreur lors de la sauvegarde du profil utilisateur.';
      return false;
    }
  }
  
  // Connexion avec email et mot de passe
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();
      
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      // La mise à jour de _status et _firebaseUser est gérée par _onAuthStateChanged
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'Aucun utilisateur trouvé pour cet email.';
          break;
        case 'wrong-password':
          _errorMessage = 'Mot de passe incorrect.';
          break;
        case 'invalid-email':
          _errorMessage = 'Format d\'email invalide.';
          break;
        case 'user-disabled':
          _errorMessage = 'Ce compte a été désactivé.';
          break;
        case 'too-many-requests':
          _errorMessage = 'Trop de tentatives. Veuillez réessayer plus tard.';
          break;
        default:
          _errorMessage = 'Erreur de connexion: ${e.message}';
      }
      
      SecurityLogger.error('Sign in error: ${e.toString()}');
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Erreur de connexion.';
      SecurityLogger.error('Sign in error: ${e.toString()}');
      notifyListeners();
      return false;
    }
  }
  
  // Inscription avec email et mot de passe
  Future<bool> registerWithEmailAndPassword(
    String email, 
    String password, 
    String username
  ) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();
      
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // Mettre à jour le nom d'utilisateur dans Firebase Auth
      await userCredential.user?.updateDisplayName(username);
      
      // Attendre que Firebase Auth soit à jour
      await _auth.currentUser?.reload();
      
      // Créer un profil utilisateur
      _userProfile = UserProfile(
        id: userCredential.user!.uid,
        username: username,
        email: email,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      
      // Sauvegarder le profil utilisateur dans Firestore
      await _saveUserProfile();
      
      // La mise à jour de _status et _firebaseUser est gérée par _onAuthStateChanged
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      
      switch (e.code) {
        case 'email-already-in-use':
          _errorMessage = 'Cet email est déjà utilisé par un autre compte.';
          break;
        case 'invalid-email':
          _errorMessage = 'Format d\'email invalide.';
          break;
        case 'operation-not-allowed':
          _errorMessage = 'Cette opération n\'est pas autorisée.';
          break;
        case 'weak-password':
          _errorMessage = 'Le mot de passe fourni est trop faible.';
          break;
        default:
          _errorMessage = 'Erreur d\'inscription: ${e.message}';
      }
      
      SecurityLogger.error('Registration error: ${e.toString()}');
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Erreur d\'inscription.';
      SecurityLogger.error('Registration error: ${e.toString()}');
      notifyListeners();
      return false;
    }
  }
  
  // Réinitialisation du mot de passe
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      SecurityLogger.error('Password reset error: ${e.toString()}');
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Erreur lors de la réinitialisation du mot de passe.';
      SecurityLogger.error('Password reset error: ${e.toString()}');
      notifyListeners();
      return false;
    }
  }
  
  // Déconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // La mise à jour de _status et _firebaseUser est gérée par _onAuthStateChanged
    } catch (e) {
      _errorMessage = 'Erreur lors de la déconnexion.';
      SecurityLogger.error('Sign out error: ${e.toString()}');
      notifyListeners();
    }
  }
  
  // Mise à jour du profil utilisateur
  Future<bool> updateProfile({
    String? username,
    String? bio,
    String? avatarUrl,
  }) async {
    if (_firebaseUser == null || _userProfile == null) return false;
    
    try {
      // Mettre à jour le nom d'affichage dans Firebase Auth si fourni
      if (username != null && username.isNotEmpty) {
        await _firebaseUser!.updateDisplayName(username);
      }
      
      // Mettre à jour l'URL de la photo dans Firebase Auth si fournie
      if (avatarUrl != null) {
        await _firebaseUser!.updatePhotoURL(avatarUrl);
      }
      
      // Mettre à jour le profil utilisateur local
      _userProfile = _userProfile!.copyWith(
        username: username ?? _userProfile!.username,
        bio: bio ?? _userProfile!.bio,
        avatarUrl: avatarUrl ?? _userProfile!.avatarUrl,
      );
      
      // Sauvegarder les modifications dans Firestore
      final success = await _saveUserProfile();
      
      // Recharger l'utilisateur Firebase pour s'assurer que les modifications sont récupérées
      await _firebaseUser!.reload();
      
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour du profil.';
      SecurityLogger.error('Update profile error: ${e.toString()}');
      notifyListeners();
      return false;
    }
  }
  
  // Modifier le mot de passe
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_firebaseUser == null || _firebaseUser!.email == null) return false;
    
    try {
      // Réauthentifier l'utilisateur avec son mot de passe actuel
      final credential = EmailAuthProvider.credential(
        email: _firebaseUser!.email!,
        password: currentPassword,
      );
      
      await _firebaseUser!.reauthenticateWithCredential(credential);
      
      // Mettre à jour le mot de passe
      await _firebaseUser!.updatePassword(newPassword);
      
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          _errorMessage = 'Mot de passe actuel incorrect.';
          break;
        case 'weak-password':
          _errorMessage = 'Le nouveau mot de passe est trop faible.';
          break;
        case 'requires-recent-login':
          _errorMessage = 'Veuillez vous reconnecter avant de changer votre mot de passe.';
          break;
        default:
          _errorMessage = 'Erreur lors du changement de mot de passe: ${e.message}';
      }
      
      SecurityLogger.error('Change password error: ${e.toString()}');
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Erreur lors du changement de mot de passe.';
      SecurityLogger.error('Change password error: ${e.toString()}');
      notifyListeners();
      return false;
    }
  }
  
  // Supprimer le compte
  Future<bool> deleteAccount(String password) async {
    if (_firebaseUser == null || _firebaseUser!.email == null) return false;
    
    try {
      // Réauthentifier l'utilisateur avec son mot de passe
      final credential = EmailAuthProvider.credential(
        email: _firebaseUser!.email!,
        password: password,
      );
      
      await _firebaseUser!.reauthenticateWithCredential(credential);
      
      // Supprimer les données de l'utilisateur dans Firestore
      await _firestore.collection('users').doc(_firebaseUser!.uid).delete();
      
      // Supprimer le compte Firebase Auth
      await _firebaseUser!.delete();
      
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          _errorMessage = 'Mot de passe incorrect.';
          break;
        case 'requires-recent-login':
          _errorMessage = 'Veuillez vous reconnecter avant de supprimer votre compte.';
          break;
        default:
          _errorMessage = 'Erreur lors de la suppression du compte: ${e.message}';
      }
      
      SecurityLogger.error('Delete account error: ${e.toString()}');
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression du compte.';
      SecurityLogger.error('Delete account error: ${e.toString()}');
      notifyListeners();
      return false;
    }
  }
  
  // Vérifier si l'email est déjà utilisé
  Future<bool> isEmailInUse(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      SecurityLogger.error('Email check error: ${e.toString()}');
      return false;
    }
  }
}