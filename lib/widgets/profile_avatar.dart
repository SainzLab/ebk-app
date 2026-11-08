import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Komponen Reusable Model Foto Profil Bulat (Round Profile Avatar).
/// Dirancang untuk tampilan Profil dan Dashboard seluruh aktor (Guru BK, Orang Tua, Kepala Sekolah):
/// - Berbentuk bulat sempurna (Circular / Round Shape) sesuai spesifikasi foto profil modern.
/// - Siap diisi dengan foto profil (melalui [image], [imageUrl], atau [assetPath]).
/// - Menampilkan fallback ikon peran atau inisial nama jika foto belum diunggah.
/// - Menyediakan badge kamera/edit untuk kemudahan aksi unggah foto di halaman profil.
class ProfileAvatar extends StatelessWidget {
  final double size;
  final ImageProvider? image;
  final String? imageUrl;
  final String? assetPath;
  final IconData? fallbackIcon;
  final String? fallbackInitials;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final bool showEditBadge;
  final VoidCallback? onEditPressed;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.size = 44.0,
    this.image,
    this.imageUrl,
    this.assetPath,
    this.fallbackIcon = Icons.person_outline_rounded,
    this.fallbackInitials,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.5,
    this.showEditBadge = false,
    this.onEditPressed,
    this.onTap,
  });

  Widget _buildFallbackContent() {
    if (fallbackInitials != null && fallbackInitials!.trim().isNotEmpty) {
      return Center(
        child: Text(
          fallbackInitials!.trim().toUpperCase(),
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryNavy,
          ),
        ),
      );
    }

    return Center(
      child: Icon(
        fallbackIcon ?? Icons.person_outline_rounded,
        size: size * 0.50,
        color: AppColors.primaryNavy,
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (image != null) {
      return Image(
        image: image!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackContent(),
      );
    }

    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return Image.network(
        imageUrl!.trim(),
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: backgroundColor ?? AppColors.primaryTint,
            alignment: Alignment.center,
            child: SizedBox(
              width: size * 0.35,
              height: size * 0.35,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryNavy,
                ),
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildFallbackContent(),
      );
    }

    if (assetPath != null && assetPath!.trim().isNotEmpty) {
      return Image.asset(
        assetPath!.trim(),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackContent(),
      );
    }

    return _buildFallbackContent();
  }

  @override
  Widget build(BuildContext context) {
    final avatarCircle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryTint,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? AppColors.borderBlueAccent,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBase.withValues(alpha: 0.08),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: _buildAvatarContent(),
      ),
    );

    if (!showEditBadge) {
      if (onTap != null) {
        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: avatarCircle,
        );
      }
      return avatarCircle;
    }

    final double badgeSize = (size * 0.36).clamp(22.0, 32.0);
    final double iconSize = (badgeSize * 0.52).clamp(11.0, 16.0);

    return SizedBox(
      width: size + 4.0,
      height: size + 4.0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 2.0,
            left: 2.0,
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: avatarCircle,
            ),
          ),
          Positioned(
            bottom: 0.0,
            right: 0.0,
            child: GestureDetector(
              onTap: onEditPressed ?? onTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.pureWhite,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowBase.withValues(alpha: 0.22),
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: iconSize,
                  color: AppColors.pureWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
