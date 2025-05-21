import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';
import '../models/user_profile.dart';
import '../utils/constants.dart';

class LocalStorageService {
  late SharedPreferences _prefs;
  
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // User Preferences Methods
  Future<UserPreferences> getUserPreferences() async {
    final prefsString = _prefs.getString(AppConstants.prefsKey);
    if (prefsString != null) {
      return UserPreferences.deserialize(prefsString);
    }
    return UserPreferences();
  }
  
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    await _prefs.setString(AppConstants.prefsKey, preferences.serialize());
  }
  
  Future<void> clearUserPreferences() async {
    await _prefs.remove(AppConstants.prefsKey);
  }
  
  // Favorites Methods
  Future<bool> toggleFavoriteMovie(int movieId) async {
    final prefs = await getUserPreferences();
    List<int> favorites = List.from(prefs.favoriteMovieIds);
    
    bool isFavorite = favorites.contains(movieId);
    if (isFavorite) {
      favorites.remove(movieId);
    } else {
      favorites.add(movieId);
    }
    
    await saveUserPreferences(
      prefs.copyWith(favoriteMovieIds: favorites)
    );
    
    return !isFavorite;
  }
  
  Future<bool> toggleFavoriteTvShow(int tvShowId) async {
    final prefs = await getUserPreferences();
    List<int> favorites = List.from(prefs.favoriteTvShowIds);
    
    bool isFavorite = favorites.contains(tvShowId);
    if (isFavorite) {
      favorites.remove(tvShowId);
    } else {
      favorites.add(tvShowId);
    }
    
    await saveUserPreferences(
      prefs.copyWith(favoriteTvShowIds: favorites)
    );
    
    return !isFavorite;
  }
  
  Future<bool> isMovieFavorite(int movieId) async {
    final prefs = await getUserPreferences();
    return prefs.favoriteMovieIds.contains(movieId);
  }
  
  Future<bool> isTvShowFavorite(int tvShowId) async {
    final prefs = await getUserPreferences();
    return prefs.favoriteTvShowIds.contains(tvShowId);
  }
  
  // Theme Preference Methods
  Future<bool> getDarkModePreference() async {
    final prefs = await getUserPreferences();
    return prefs.darkMode;
  }
  
  Future<void> setDarkModePreference(bool darkMode) async {
    final prefs = await getUserPreferences();
    await saveUserPreferences(prefs.copyWith(darkMode: darkMode));
  }
  
  // User Profile Methods
  Future<UserProfile?> getUserProfile() async {
    final profileString = _prefs.getString(AppConstants.profileKey);
    if (profileString != null) {
      return UserProfile.deserialize(profileString);
    }
    return null;
  }
  
  Future<void> saveUserProfile(UserProfile profile) async {
    await _prefs.setString(AppConstants.profileKey, profile.serialize());
  }
  
  Future<void> clearUserProfile() async {
    await _prefs.remove(AppConstants.profileKey);
  }

  // Genre Preferences Methods
  Future<void> updatePreferredGenres(List<String> genres) async {
    final prefs = await getUserPreferences();
    await saveUserPreferences(prefs.copyWith(preferredGenres: genres));
  }
}