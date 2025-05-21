import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/image_service.dart';
import '../../utils/constants.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile userProfile;
  final VoidCallback onEditProfile;
  final ImageService imageService;

  const ProfileHeader({
    super.key,
    required this.userProfile,
    required this.onEditProfile,
    required this.imageService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accent,
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
                child: Hero(
                  tag: 'profile_avatar',
                  child: ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: Image(
                        image: imageService.getProfileImageProvider(userProfile.avatarUrl),
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.primaryDark,
                            width: 120,
                            height: 120,
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.accent,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onEditProfile,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
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
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          if (userProfile.bio != null && userProfile.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                userProfile.bio!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}