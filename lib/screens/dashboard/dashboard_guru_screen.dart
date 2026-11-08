import 'package:flutter/material.dart';
import '../../models/case_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/toast_notification.dart';
import '../../widgets/animated_indexed_stack.dart';
import '../../widgets/profile_avatar.dart';
import '../features/jadwal_konseling_screen.dart';
import '../features/kelola_kasus_screen.dart';
import '../features/tambah_kasus_screen.dart';
import '../features/detail_kasus_screen.dart';
import '../features/catat_konsultasi_screen.dart';
import '../features/kelola_pengguna_screen.dart';
import '../features/data_siswa_screen.dart';
import 'profil_view.dart';

enum _GuruSubView {
  dataSiswa,
  catatKonsultasi,
  kelolaPengguna,
  tambahKasus,
  detailKasus,
}

/// Halaman Dashboard Guru BK (`03 • Dashboard Guru BK`)
/// berdasarkan `03-dashboard-guru-bk.png` dan `ebk_design.json`.
class DashboardGuruScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const DashboardGuruScreen({
    super.key,
    this.onLogout,
  });

  @override
  State<DashboardGuruScreen> createState() => _DashboardGuruScreenState();
}

class _DashboardGuruScreenState extends State<DashboardGuruScreen> {
  int _selectedNavIndex = 0;
  _GuruSubView? _activeSubView;
  _GuruSubView? _previousSubView;
  CaseRecordModel? _selectedCaseForDetail;
  CaseRecordModel? _caseToEdit;

  void _onNavTap(int index) {
    setState(() {
      _selectedNavIndex = index;
      _activeSubView = null;
      _previousSubView = null;
      _selectedCaseForDetail = null;
      _caseToEdit = null;
    });
  }

  void _openSubView(_GuruSubView subView) {
    setState(() {
      _previousSubView = _activeSubView;
      _activeSubView = subView;
    });
  }

  void _closeSubView() {
    setState(() {
      _activeSubView = _previousSubView;
      _previousSubView = null;
      if (_activeSubView == null) {
        _selectedCaseForDetail = null;
        _caseToEdit = null;
      }
    });
  }

  void _handleLogout() {
    if (widget.onLogout != null) {
      widget.onLogout!();
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildSubView() {
    switch (_activeSubView!) {
      case _GuruSubView.dataSiswa:
        return DataSiswaScreen(
          onBack: _closeSubView,
          onOpenDetail: (caseItem) {
            setState(() {
              _selectedCaseForDetail = caseItem;
              _previousSubView = _GuruSubView.dataSiswa;
              _activeSubView = _GuruSubView.detailKasus;
            });
          },
        );
      case _GuruSubView.catatKonsultasi:
        return CatatKonsultasiScreen(
          onBack: _closeSubView,
        );
      case _GuruSubView.kelolaPengguna:
        return KelolaPenggunaScreen(
          isEmbedded: true,
          onBack: _closeSubView,
        );
      case _GuruSubView.tambahKasus:
        return TambahKasusScreen(
          initialCase: _caseToEdit,
          isEmbedded: true,
          onBack: _closeSubView,
          onSaveSuccess: (saved) {
            _closeSubView();
            ToastNotification.show(
              context,
              message: 'Berhasil: Kasus ${saved.caseTitle} telah disimpan.',
              type: ToastType.success,
            );
          },
        );
      case _GuruSubView.detailKasus:
        return DetailKasusScreen(
          caseData: _selectedCaseForDetail,
          onBack: _closeSubView,
          onOpenEdit: (caseToEdit) {
            setState(() {
              _caseToEdit = caseToEdit;
              _previousSubView = _GuruSubView.detailKasus;
              _activeSubView = _GuruSubView.tambahKasus;
            });
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _activeSubView == null && _selectedNavIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (_activeSubView != null) {
            _closeSubView();
          } else if (_selectedNavIndex != 0) {
            setState(() => _selectedNavIndex = 0);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.canvasLightGray,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.035, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _activeSubView != null
              ? KeyedSubtree(
                  key: ValueKey(_activeSubView),
                  child: _buildSubView(),
                )
              : KeyedSubtree(
                  key: const ValueKey('guru_main_tabs'),
                  child: AnimatedIndexedStack(
                    index: _selectedNavIndex,
                    children: [
                      _buildHomeContent(),
                      JadwalKonselingScreen(
                        onBack: () => setState(() => _selectedNavIndex = 0),
                      ),
                      KelolaKasusScreen(
                        onBack: () => setState(() => _selectedNavIndex = 0),
                        onOpenDetail: (caseItem) {
                          setState(() {
                            _selectedCaseForDetail = caseItem;
                            _previousSubView = null;
                            _activeSubView = _GuruSubView.detailKasus;
                          });
                        },
                        onOpenTambah: (caseToEdit) {
                          setState(() {
                            _caseToEdit = caseToEdit;
                            _previousSubView = null;
                            _activeSubView = _GuruSubView.tambahKasus;
                          });
                        },
                      ),
                      ProfilView(
                        role: ProfilRole.guruBk,
                        onLogout: _handleLogout,
                        onBack: () => setState(() => _selectedNavIndex = 0),
                      ),
                    ],
                  ),
                ),
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _selectedNavIndex,
          items: CustomBottomNav.guruItems,
          onTap: _onNavTap,
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 20.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar (SRS-F-002)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profil & Sapaan
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ProfileAvatar(
                            size: 44.0,
                            fallbackIcon: Icons.person_outline_rounded,
                            onTap: () => setState(() => _selectedNavIndex = 3),
                          ),
                          const SizedBox(width: 12.0),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'E-BK SMPN 1 Pabuaran',
                                  style: AppTextStyles.captionSemibold11,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.0),
                                Text(
                                  'Halo, Guru BK',
                                  style: AppTextStyles.greetingGuru,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18.0),
              // Card Ringkasan Cepat (r=24, fill=#1B3B7B, pad=18, gap=14)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryNavy.withValues(alpha: 0.20),
                      offset: const Offset(0, 8),
                      blurRadius: 20.0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ringkasan Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Text(
                            'Ringkasan Cepat',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 13.0,
                              height: 18.0 / 13.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.borderBlueTint,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 10.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.circular(99.0),
                            border: Border.all(
                              color:
                                  AppColors.blueAccent.withValues(alpha: 0.33),
                              width: 1.0,
                            ),
                          ),
                          child: const Text(
                            'Sabtu, 7 Nov 2026',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blueLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14.0),
                    // Metrics Auto-Layout Row
                    Row(
                      children: [
                        Expanded(
                          child: _QuickSummarySubcard(
                            value: '08',
                            label: 'Kasus Diproses',
                            icon: Icons.folder_outlined,
                            onTap: () => _onNavTap(2),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: _QuickSummarySubcard(
                            value: '05',
                            label: 'Jadwal Konseling\nHari Ini',
                            icon: Icons.calendar_today_outlined,
                            onTap: () => _onNavTap(1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18.0),
              // Section Grid Menu Navigasi (gap: 12.0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Expanded(
                    child: Text(
                      'Menu Layanan BK',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sectionHeader16,
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    'Pilih Modul',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12.0,
                      height: 16.0 / 12.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              // Menu Row 1 (height: 122.0)
              Row(
                children: [
                  Expanded(
                    child: _MenuGridCard(
                      height: 132.0,
                      icon: Icons.people_outline_rounded,
                      badgeText: '640 Siswa',
                      title: 'Data Siswa',
                      subtitle: 'Profil & kelas siswa',
                      onTap: () => _openSubView(_GuruSubView.dataSiswa),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _MenuGridCard(
                      height: 132.0,
                      icon: Icons.assignment_outlined,
                      badgeText: '8 Proses',
                      title: 'Data Kasus',
                      subtitle: 'Catatan & pembinaan',
                      onTap: () => _onNavTap(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              // Menu Row 2 (height: 132.0)
              Row(
                children: [
                  Expanded(
                    child: _MenuGridCard(
                      height: 132.0,
                      icon: Icons.chat_outlined,
                      badgeText: '5 Jadwal',
                      title: 'Layanan Konseling',
                      subtitle: 'Sesi & jadwal bimbingan',
                      onTap: () => _onNavTap(1),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: _MenuGridCard(
                      height: 132.0,
                      icon: Icons.forum_outlined,
                      badgeText: '3 Pesan',
                      title: 'Konsul Orang Tua',
                      subtitle: 'Komunikasi wali murid',
                      onTap: () =>
                          _openSubView(_GuruSubView.catatKonsultasi),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              // Kelola Pengguna (SRS-F-007) Wide Card
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 72.0),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: AppColors.borderNeutral,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowBase.withValues(alpha: 0.039),
                      offset: const Offset(0, 6),
                      blurRadius: 18.0,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        _openSubView(_GuruSubView.kelolaPengguna),
                    borderRadius: BorderRadius.circular(20.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 13.0,
                        horizontal: 15.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 44.0,
                                  height: 44.0,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryTint,
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.verified_user_outlined,
                                    size: 22.0,
                                    color: AppColors.primaryNavy,
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Kelola Pengguna',
                                        style: TextStyle(
                                          fontFamily: AppTextStyles.fontFamily,
                                          fontSize: 14.0,
                                          height: 19.0 / 14.0,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 2.0),
                                      Text(
                                        'Akun orang tua siswa',
                                        style: AppTextStyles.subtitle11,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 9.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.canvasLightGray,
                                  borderRadius: BorderRadius.circular(99.0),
                                ),
                                child: const Text(
                                  '640 Akun',
                                  style: AppTextStyles.badgeSemibold10,
                                ),
                              ),
                              const SizedBox(width: 6.0),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 16.0,
                                color: AppColors.textPlaceholder,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

class _QuickSummarySubcard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _QuickSummarySubcard({
    required this.value,
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 98.0,
        padding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 14.0,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: AppColors.blueAccent.withValues(alpha: 0.30),
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 26.0,
                    height: 32.0 / 26.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pureWhite,
                  ),
                ),
                Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(9.0),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: 18.0,
                    color: AppColors.blueLight,
                  ),
                ),
              ],
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12.0,
                height: 16.0 / 12.0,
                fontWeight: FontWeight.w600,
                color: AppColors.borderBlueTint,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuGridCard extends StatelessWidget {
  final double height;
  final IconData icon;
  final String badgeText;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _MenuGridCard({
    required this.height,
    required this.icon,
    required this.badgeText,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: AppColors.borderNeutral,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBase.withValues(alpha: 0.039),
            offset: const Offset(0, 6),
            blurRadius: 18.0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44.0,
                      height: 44.0,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        icon,
                        size: 22.0,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.canvasLightGray,
                        borderRadius: BorderRadius.circular(99.0),
                      ),
                      child: Text(
                        badgeText,
                        style: AppTextStyles.badgeSemibold10,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14.0,
                        height: 19.0 / 14.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      subtitle,
                      style: AppTextStyles.subtitle11,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
