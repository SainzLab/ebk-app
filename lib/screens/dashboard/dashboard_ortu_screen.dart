import 'package:flutter/material.dart';
import '../../core/auth_service.dart';
import '../../models/case_model.dart';
import '../../models/student_model.dart';
import '../../repositories/case_repository.dart';
import '../../repositories/student_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/case_card.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/animated_indexed_stack.dart';
import '../../widgets/profile_avatar.dart';
import '../features/ajukan_konsultasi_screen.dart';
import '../features/detail_kasus_screen.dart';
import 'profil_view.dart';

/// Halaman Dashboard Orang Tua (`04 • Dashboard Orang Tua`)
/// berdasarkan `04-dashboard-orang-tua.png` dan `ebk_design.json`.
class DashboardOrtuScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const DashboardOrtuScreen({
    super.key,
    this.onLogout,
  });

  @override
  State<DashboardOrtuScreen> createState() => _DashboardOrtuScreenState();
}

class _DashboardOrtuScreenState extends State<DashboardOrtuScreen> {
  int _selectedNavIndex = 0;

  static final List<CaseRecordModel> _parentCases = [
    const CaseRecordModel(
      id: '#BK-2026-049',
      studentName: 'Rizky Pratama',
      studentNisn: '0094821034',
      studentClass: 'Kelas IX-B',
      caseCategory: 'Kedisiplinan Waktu',
      caseTitle: 'Terlambat Hadir Apel Pagi',
      incidentTime: 'Kamis, 05 Nov 2026 • 07:20 WIB',
      incidentLocation: 'Gerbang Utama Sekolah',
      chronology: 'Pendampingan manajemen waktu pagi bersama Guru BK & Wali Kelas.',
      handling: 'Konseling kedisiplinan dan kesepakatan komitmen waktu bangun pagi.',
      handlingDate: 'Jumat, 06 Nov 2026',
      counselorName: 'Ibu Dra. Nurhayati, S.Pd.',
      isCompleted: false,
      violationPoints: 10,
    ),
    CaseRecordModel.defaultCases[2],
  ];

  late List<CaseRecordModel> _cases;
  late CaseRecordModel _selectedCase;
  List<StudentDataModel> _children = const [];

  @override
  void initState() {
    super.initState();
    _cases = List.from(_parentCases);
    _selectedCase = _cases.first;
    _loadOrtuDataFromPocketBase();
  }

  Future<void> _loadOrtuDataFromPocketBase() async {
    try {
      final myChildren = await StudentRepository.instance.getMyChildren();
      final myCases = await CaseRepository.instance.getCases();
      if (!mounted) return;
      setState(() {
        if (myChildren.isNotEmpty) {
          _children = myChildren;
        }
        if (myCases.isNotEmpty) {
          _cases = myCases;
          _selectedCase = _cases.first;
        }
      });
    } catch (_) {}
  }

  String get _greetingText {
    final name = AuthService.instance.currentUser?.getStringValue('name') ?? '';
    return name.isNotEmpty ? 'Halo, $name' : 'Halo, Ibu Siti Rahma';
  }

  String get _childrenSubtitle {
    if (_children.isEmpty) {
      return 'Wali dari Rizky Pratama • Kelas IX-B';
    }
    if (_children.length == 1) {
      final c = _children.first;
      return 'Wali dari ${c.name} • ${c.className}';
    }
    final names = _children.map((c) => c.name).join(', ');
    return 'Wali dari ${_children.length} Siswa ($names)';
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
  }

  Future<void> _handleLogout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    if (widget.onLogout != null) {
      widget.onLogout!();
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedNavIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedNavIndex != 0) {
          setState(() {
            _selectedNavIndex = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.canvasLightGray,
        body: AnimatedIndexedStack(
          index: _selectedNavIndex,
          children: [
            _buildHomeContent(),
            DetailKasusScreen(
              key: ValueKey(_selectedCase.id),
              caseData: _selectedCase,
              role: ProfilRole.orangTua,
              isReadOnly: true,
              onBack: () => setState(() => _selectedNavIndex = 0),
            ),
            AjukanKonsultasiScreen(
              isEmbedded: true,
              onBack: () => setState(() => _selectedNavIndex = 0),
            ),
            ProfilView(
              role: ProfilRole.orangTua,
              onLogout: _handleLogout,
              onBack: () => setState(() => _selectedNavIndex = 0),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _selectedNavIndex,
          items: CustomBottomNav.ortuItems,
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
              // Top Bar Orang Tua (height: 48.0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ProfileAvatar.currentUser(
                            size: 44.0,
                            fallbackIcon: Icons.person_outline_rounded,
                            onTap: () => setState(() => _selectedNavIndex = 3),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _greetingText,
                                  style: AppTextStyles.greetingActor,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  _childrenSubtitle,
                                  style: AppTextStyles.subtitle11,
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
              const SizedBox(height: 16.0),
              // Banner Pendampingan Positif (r=16, fill=#EBF2FF, stroke=#DBEAFE, pad=[11, 14], gap=10)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 11.0,
                  horizontal: 14.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: AppColors.borderBlueTint,
                    width: 1.0,
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 18.0,
                      color: AppColors.primaryNavy,
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: Text(
                        'Catatan bimbingan dibagikan secara transparan untuk mendukung tumbuh kembang positif ananda.',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 11.0,
                          height: 16.0 / 11.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              // Section Laporan Kasus Anak (SRS-F-008 & 009)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    'Laporan Kasus Anak',
                    style: AppTextStyles.sectionHeader15,
                  ),
                  Text(
                    'Semester Ganjil',
                    style: AppTextStyles.captionSemibold11,
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              ...List.generate(_cases.length, (i) {
                final c = _cases[i];
                return Padding(
                  padding: EdgeInsets.only(bottom: i < _cases.length - 1 ? 10.0 : 0.0),
                  child: CaseCard(
                    title: c.caseTitle,
                    description: c.chronology,
                    dateTimeText: c.incidentTime,
                    status: c.isCompleted
                        ? CaseStatus.completed
                        : CaseStatus.inProgress,
                    onTap: () {
                      setState(() {
                        _selectedCase = c;
                        _selectedNavIndex = 1;
                      });
                    },
                  ),
                );
              }),
              const SizedBox(height: 16.0),
              // Section Konsultasi (SRS-F-010 & 011)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    'Konsultasi',
                    style: AppTextStyles.sectionHeader15,
                  ),
                  Text(
                    'Layanan Wali Murid',
                    style: AppTextStyles.captionSemibold11,
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              // Card Jadwal Konsultasi Terdekat (SRS-F-010)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 14.0,
                  horizontal: 15.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(
                    color: AppColors.borderBlueTint,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryNavy.withValues(alpha: 0.059),
                      offset: const Offset(0, 6),
                      blurRadius: 16.0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Judul Jadwal Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Jadwal Konsultasi Terdekat',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13.0,
                            height: 18.0 / 13.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 3.0,
                            horizontal: 9.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTint,
                            borderRadius: BorderRadius.circular(99.0),
                          ),
                          child: const Text(
                            'Tatap Muka',
                            style: AppTextStyles.badgeSemibold10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    // Detail Jadwal Row
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.inputSurfaceGray,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 38.0,
                            height: 38.0,
                            decoration: BoxDecoration(
                              color: AppColors.primaryTint,
                              borderRadius: BorderRadius.circular(11.0),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.calendar_today_outlined,
                              size: 20.0,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Selasa, 10 Nov 2026 • 10:00 WIB',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 12.0,
                                    height: 17.0 / 12.0,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2.0),
                                Text(
                                  'Ruang BK • Ibu Dra. Nurhayati, S.Pd.',
                                  style: AppTextStyles.subtitle11,
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
              const SizedBox(height: 10.0),
              // CTA Sekunder - Ajukan Konsultasi Baru (SRS-F-011)
              CustomButton.secondary(
                label: 'Ajukan Konsultasi Baru',
                height: 49.0,
                onPressed: () {
                  setState(() {
                    _selectedNavIndex = 2;
                  });
                },
              ),
            ],
          ),
        ),
      );
  }
}
