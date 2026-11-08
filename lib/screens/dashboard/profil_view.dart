import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/toast_notification.dart';
import '../../widgets/animated_dialog.dart';
import '../../widgets/profile_avatar.dart';

/// Peran Pengguna untuk Tampilan Profil
enum ProfilRole {
  guruBk,
  orangTua,
  kepalaSekolah,
}

/// Tampilan Profil Terpadu untuk Guru BK, Orang Tua, dan Kepala Sekolah
/// Sesuai standar desain `ebk_design.json` dan tidak menghilangkan bottom navigation bar.
class ProfilView extends StatefulWidget {
  final ProfilRole role;
  final VoidCallback? onLogout;
  final VoidCallback? onBack;

  const ProfilView({
    super.key,
    required this.role,
    this.onLogout,
    this.onBack,
  });

  @override
  State<ProfilView> createState() => _ProfilViewState();
}

class _ProfilViewState extends State<ProfilView> {
  bool _notifikasiAktif = true;
  bool _emailNotifikasi = true;
  String? _profilePhotoUrl;

  String get _title {
    switch (widget.role) {
      case ProfilRole.guruBk:
        return 'Profil Guru BK';
      case ProfilRole.orangTua:
        return 'Profil Wali Murid';
      case ProfilRole.kepalaSekolah:
        return 'Profil Kepala Sekolah';
    }
  }

  String get _name {
    switch (widget.role) {
      case ProfilRole.guruBk:
        return 'Dra. Nurhayati, M.Pd.';
      case ProfilRole.orangTua:
        return 'Bpk. Hendra Pratama';
      case ProfilRole.kepalaSekolah:
        return 'Drs. H. Mulyadi, M.M.';
    }
  }

  String get _subDetail {
    switch (widget.role) {
      case ProfilRole.guruBk:
        return 'NIP. 19780512 200501 2 004\nKoordinator Bimbingan Konseling';
      case ProfilRole.orangTua:
        return 'Wali dari Ahmad Fauzi\nKelas VIII-B • NISN: 0081234567';
      case ProfilRole.kepalaSekolah:
        return 'NIP. 19680315 199303 1 002\nKepala Sekolah SMPN 1 Pabuaran';
    }
  }

  String get _email {
    switch (widget.role) {
      case ProfilRole.guruBk:
        return 'nurhayati.bk@smpn1pabuaran.sch.id';
      case ProfilRole.orangTua:
        return 'hendra.pratama@gmail.com';
      case ProfilRole.kepalaSekolah:
        return 'mulyadi.kepsek@smpn1pabuaran.sch.id';
    }
  }

  String get _phone {
    switch (widget.role) {
      case ProfilRole.guruBk:
        return '+62 812-3456-7890';
      case ProfilRole.orangTua:
        return '+62 821-9876-5432';
      case ProfilRole.kepalaSekolah:
        return '+62 811-2233-4455';
    }
  }

  IconData get _roleIcon {
    switch (widget.role) {
      case ProfilRole.guruBk:
        return Icons.school_outlined;
      case ProfilRole.orangTua:
        return Icons.family_restroom_outlined;
      case ProfilRole.kepalaSekolah:
        return Icons.account_balance_outlined;
    }
  }

  void _confirmLogout() {
    showAnimatedDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: AppColors.pureWhite,
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  width: 52.0,
                  height: 52.0,
                  decoration: const BoxDecoration(
                    color: AppColors.errorLightBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.errorPrimary,
                    size: 26.0,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Konfirmasi Keluar',
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Apakah Anda yakin ingin keluar dari aplikasi E-BK SMPN 1 Pabuaran?',
                style: AppTextStyles.bodyText12,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22.0),
              Row(
                children: [
                  Expanded(
                    child: CustomButton.secondary(
                      label: 'Batal',
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: CustomButton.danger(
                      label: 'Keluar',
                      onPressed: () {
                        Navigator.pop(ctx);
                        if (widget.onLogout != null) {
                          widget.onLogout!();
                        } else {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showAnimatedDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: AppColors.pureWhite,
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.heading2),
              const SizedBox(height: 12.0),
              Text(
                content,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13.0,
                  height: 1.5,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20.0),
              CustomButton.primary(
                label: 'Tutup',
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: AppColors.borderNeutral,
                      borderRadius: BorderRadius.circular(99.0),
                    ),
                  ),
                ),
                const SizedBox(height: 18.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ubah Foto Profil',
                      style: AppTextStyles.heading2,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20.0),
                      onPressed: () => Navigator.pop(ctx),
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryTint,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.primaryNavy,
                      size: 20.0,
                    ),
                  ),
                  title: const Text(
                    'Ambil Foto dari Kamera',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _profilePhotoUrl =
                          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=256';
                    });
                    ToastNotification.show(
                      context,
                      message: 'Foto profil berhasil diperbarui dari kamera.',
                      type: ToastType.success,
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryTint,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.primaryNavy,
                      size: 20.0,
                    ),
                  ),
                  title: const Text(
                    'Pilih dari Galeri',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _profilePhotoUrl =
                          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=256';
                    });
                    ToastNotification.show(
                      context,
                      message: 'Foto profil berhasil dipilih dari galeri.',
                      type: ToastType.success,
                    );
                  },
                ),
                if (_profilePhotoUrl != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: const BoxDecoration(
                        color: AppColors.errorLightBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.errorPrimary,
                        size: 20.0,
                      ),
                    ),
                    title: const Text(
                      'Hapus Foto Profil',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.errorPrimary,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _profilePhotoUrl = null;
                      });
                      ToastNotification.show(
                        context,
                        message: 'Foto profil dihapus, kembali ke avatar peran.',
                        type: ToastType.success,
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasLightGray,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Profil Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.onBack != null)
                      GestureDetector(
                        onTap: widget.onBack,
                        child: Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: AppColors.pureWhite,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: AppColors.borderNeutral,
                              width: 1.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            size: 18.0,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 40.0, height: 40.0),
                    
                    // --- JUDUL PROFIL ---
                    Text(
                      _title,
                      style: AppTextStyles.topBarTitle,
                    ),

                    // --- PENYEIMBANG AGAR JUDUL PRESISI DI TENGAH ---
                    const SizedBox(width: 40.0), 
                  ],
                ),
              ),
              const SizedBox(height: 18.0),

              // Kartu Ringkasan Pengguna
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: AppColors.borderBlueAccent,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowBase.withValues(alpha: 0.04),
                      offset: const Offset(0, 6),
                      blurRadius: 18.0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileAvatar(
                          size: 64.0,
                          imageUrl: _profilePhotoUrl,
                          fallbackIcon: _roleIcon,
                          fallbackInitials: widget.role == ProfilRole.guruBk
                              ? 'NH'
                              : (widget.role == ProfilRole.orangTua
                                  ? 'HP'
                                  : 'MY'),
                          showEditBadge: true,
                          onTap: _showPhotoPickerSheet,
                        ),
                        const SizedBox(width: 14.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _name,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                _subDetail,
                                style: AppTextStyles.subtitle11,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    const Divider(height: 1.0, color: AppColors.borderNeutral),
                    const SizedBox(height: 14.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Status Akun',
                          style: AppTextStyles.label,
                        ),
                        const SizedBox(width: 8.0),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDEF7EC),
                              borderRadius: BorderRadius.circular(99.0),
                            ),
                            child: const Text(
                              'Aktif & Terverifikasi',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 11.0,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF03543F),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18.0),

              // Seksi Informasi Akun
              const Text(
                'Informasi Akun',
                style: AppTextStyles.sectionHeader16,
              ),
              const SizedBox(height: 10.0),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: AppColors.borderNeutral,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    _InfoTile(
                      icon: Icons.alternate_email_rounded,
                      title: 'Email Terdaftar',
                      value: _email,
                    ),
                    const Divider(height: 1.0, color: AppColors.borderNeutral),
                    _InfoTile(
                      icon: Icons.phone_android_rounded,
                      title: 'Nomor Telepon / WhatsApp',
                      value: _phone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18.0),

              // Seksi Preferensi & Notifikasi
              const Text(
                'Preferensi & Notifikasi',
                style: AppTextStyles.sectionHeader16,
              ),
              const SizedBox(height: 10.0),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: AppColors.borderNeutral,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.notifications_active_outlined,
                                size: 20.0,
                                color: AppColors.primaryNavy,
                              ),
                              SizedBox(width: 12.0),
                              Text(
                                'Notifikasi Sistem',
                                style: AppTextStyles.label,
                              ),
                            ],
                          ),
                          Switch(
                            value: _notifikasiAktif,
                            activeColor: AppColors.primaryNavy,
                            onChanged: (val) {
                              setState(() => _notifikasiAktif = val);
                              ToastNotification.show(
                                context,
                                message: val
                                    ? 'Notifikasi sistem telah diaktifkan'
                                    : 'Notifikasi sistem telah dinonaktifkan',
                                type: ToastType.success,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1.0, color: AppColors.borderNeutral),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.mark_email_read_outlined,
                                size: 20.0,
                                color: AppColors.primaryNavy,
                              ),
                              SizedBox(width: 12.0),
                              Text(
                                'Notifikasi Email',
                                style: AppTextStyles.label,
                              ),
                            ],
                          ),
                          Switch(
                            value: _emailNotifikasi,
                            activeColor: AppColors.primaryNavy,
                            onChanged: (val) {
                              setState(() => _emailNotifikasi = val);
                              ToastNotification.show(
                                context,
                                message: val
                                    ? 'Notifikasi email telah diaktifkan'
                                    : 'Notifikasi email telah dinonaktifkan',
                                type: ToastType.success,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18.0),

              // Seksi Bantuan & Informasi Aplikasi
              const Text(
                'Layanan & Bantuan',
                style: AppTextStyles.sectionHeader16,
              ),
              const SizedBox(height: 10.0),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: AppColors.borderNeutral,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    _ActionTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Pusat Bantuan & Panduan Pengguna',
                      onTap: () => _showInfoDialog(
                        'Pusat Bantuan E-BK',
                        'Aplikasi E-BK SMPN 1 Pabuaran dirancang untuk memfasilitasi pencatatan kasus, penjadwalan bimbingan konseling, dan konsultasi interaktif antara guru BK, wali murid, dan kepala sekolah.\n\nUntuk kendala teknis silakan hubungi tim administrasi sekolah.',
                      ),
                    ),
                    const Divider(height: 1.0, color: AppColors.borderNeutral),
                    _ActionTile(
                      icon: Icons.shield_outlined,
                      title: 'Kebijakan Privasi & Perlindungan Data',
                      onTap: () => _showInfoDialog(
                        'Kebijakan Privasi',
                        'Seluruh data siswa, catatan bimbingan konseling, dan riwayat konsultasi bersifat rahasia dan dilindungi sesuai kode etik bimbingan konseling nasional dan standar keamanan data pendidikan SMPN 1 Pabuaran.',
                      ),
                    ),
                    const Divider(height: 1.0, color: AppColors.borderNeutral),
                    _ActionTile(
                      icon: Icons.info_outline_rounded,
                      title: 'Tentang Aplikasi E-BK',
                      onTap: () => _showInfoDialog(
                        'Tentang E-BK SMPN 1 Pabuaran',
                        'E-BK SMPN 1 Pabuaran v1.0.0\nSistem Terintegrasi Layanan Bimbingan & Konseling Sekolah Menengah Pertama Negeri 1 Pabuaran.\n\n© 2026 Hak Cipta Dilindungi.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // Tombol Keluar Utama
              CustomButton.danger(
                label: 'Keluar dari Akun',
                height: 48.0,
                onPressed: _confirmLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.0, color: AppColors.primaryNavy),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle11),
                const SizedBox(height: 2.0),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, size: 20.0, color: AppColors.primaryNavy),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20.0,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}