import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class SettingsMenu extends StatelessWidget {
  final bool darkMode;
  final Function(bool) onDarkModeChanged;
  final VoidCallback onLogout;

  const SettingsMenu({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Text(
              'Paramètres',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Container(
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
            title: const Text('Mode sombre'),
            trailing: Switch(
              value: darkMode,
              onChanged: onDarkModeChanged,
              activeColor: AppColors.accent,
            ),
          ),
          ListTile(
            leading: Container(
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
            title: const Text('Notifications'),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: AppColors.accent,
            ),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.language,
                color: AppColors.accent,
              ),
            ),
            title: const Text('Langue'),
            trailing: const Text('Français'),
            onTap: () {},
          ),
          const Divider(),
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
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class GenrePreferenceCard extends StatelessWidget {
  final List<String> selectedGenres;
  final List<String> availableGenres;
  final Function(List<String>) onGenresChanged;

  const GenrePreferenceCard({
    super.key,
    required this.selectedGenres,
    required this.availableGenres,
    required this.onGenresChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Genres préférés',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableGenres.map((genre) {
                final isSelected = selectedGenres.contains(genre);
                return FilterChip(
                  label: Text(genre),
                  selected: isSelected,
                  selectedColor: AppColors.accent.withOpacity(0.7),
                  backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  onSelected: (selected) {
                    List<String> newGenres = List.from(selectedGenres);
                    if (selected) {
                      newGenres.add(genre);
                    } else {
                      newGenres.remove(genre);
                    }
                    onGenresChanged(newGenres);
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}