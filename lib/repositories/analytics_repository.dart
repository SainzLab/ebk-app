import 'package:pocketbase/pocketbase.dart';
import '../core/app_exception.dart';
import '../core/pb_client.dart';
import '../models/case_model.dart';

enum KepsekFilterMode {
  date,
  dateRange,
  year,
}

class GradeCaseSummary {
  final String gradeLevel;
  final int totalCases;
  final int completedCases;
  final double percentage;
  final double progressFraction;

  const GradeCaseSummary({
    required this.gradeLevel,
    required this.totalCases,
    required this.completedCases,
    this.percentage = 0.0,
    this.progressFraction = 0.0,
  });
}

class CategoryCaseSummary {
  final String categoryName;
  final int caseCount;
  final double percentage;
  final double progressFraction;

  const CategoryCaseSummary({
    required this.categoryName,
    required this.caseCount,
    this.percentage = 0.0,
    this.progressFraction = 0.0,
  });
}

class MonthlyCaseTrend {
  final String month;
  final int count;
  final double fillHeight;
  final bool isCurrent;

  const MonthlyCaseTrend({
    required this.month,
    required this.count,
    required this.fillHeight,
    this.isCurrent = false,
  });
}

class TopStudentCaseRank {
  final String studentId;
  final String studentName;
  final String studentClass;
  final String studentNisn;
  final int caseCount;
  final int totalPoints;

  const TopStudentCaseRank({
    required this.studentId,
    required this.studentName,
    required this.studentClass,
    required this.studentNisn,
    required this.caseCount,
    required this.totalPoints,
  });
}

class DashboardAnalyticsSummary {
  final int totalStudents;
  final int totalCases;
  final int completedCases;
  final int activeCases;
  final int totalSessions;
  final int totalParents;
  final int totalConsultations;
  final int pendingRequests;
  final List<GradeCaseSummary> byGrade;
  final List<TopStudentCaseRank> topStudents;

  const DashboardAnalyticsSummary({
    required this.totalStudents,
    required this.totalCases,
    required this.completedCases,
    required this.activeCases,
    required this.totalSessions,
    this.totalParents = 0,
    this.totalConsultations = 0,
    this.pendingRequests = 0,
    required this.byGrade,
    required this.topStudents,
  });
}

class KepsekAnalyticsData {
  final int totalStudents;
  final int totalCases;
  final int completedCases;
  final double completionRate;
  final String completionBadgeText;
  final double caseChangePercentage;
  final String caseBadgeText;
  final bool isCaseDecreased;
  final String trendSummaryText;
  final String trendPeriodSubtitle;
  final List<MonthlyCaseTrend> monthlyBars;
  final List<GradeCaseSummary> gradeDistributions;
  final List<CategoryCaseSummary> categoryDistributions;
  final List<TopStudentCaseRank> topStudents;
  final String periodName;

  const KepsekAnalyticsData({
    required this.totalStudents,
    required this.totalCases,
    required this.completedCases,
    required this.completionRate,
    required this.completionBadgeText,
    required this.caseChangePercentage,
    required this.caseBadgeText,
    required this.isCaseDecreased,
    required this.trendSummaryText,
    required this.trendPeriodSubtitle,
    required this.monthlyBars,
    required this.gradeDistributions,
    required this.categoryDistributions,
    required this.topStudents,
    required this.periodName,
  });
}

class AnalyticsRepository {
  AnalyticsRepository._();
  static final AnalyticsRepository instance = AnalyticsRepository._();

  PocketBase get _pb => PbClient.instance;

  static const List<String> _monthNamesShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  Future<DashboardAnalyticsSummary> getSummary() async {
    try {
      final studentsList = await _pb
          .collection('students')
          .getList(page: 1, perPage: 1);
      final casesRecords = await _pb.collection('cases').getFullList();
      final sessionsList = await _pb
          .collection('counseling_sessions')
          .getList(page: 1, perPage: 1);

      final totalStudents = studentsList.totalItems;
      final totalCases = casesRecords.length;
      final completedCases =
          casesRecords.where((c) => c.getBoolValue('is_completed')).length;
      final activeCases = totalCases - completedCases;

      List<GradeCaseSummary> byGrade = [];
      try {
        final gradeRecs = await _pb.collection('v_cases_by_grade').getFullList();
        byGrade = gradeRecs
            .map(
              (r) => GradeCaseSummary(
                gradeLevel: r.getStringValue('grade_level'),
                totalCases: r.getIntValue('total_cases'),
                completedCases: r.getIntValue('completed_cases'),
              ),
            )
            .toList();
      } catch (_) {}

      List<TopStudentCaseRank> topStudents = [];
      try {
        final topRecs = await _pb
            .collection('v_top_students_cases')
            .getFullList(sort: '-case_count,-total_points');
        topStudents = topRecs
            .take(5)
            .map(
              (r) => TopStudentCaseRank(
                studentId: r.id,
                studentName: r.getStringValue('student_name'),
                studentClass: r.getStringValue('student_class'),
                studentNisn: r.getStringValue('student_nisn'),
                caseCount: r.getIntValue('case_count'),
                totalPoints: r.getIntValue('total_points'),
              ),
            )
            .toList();
      } catch (_) {}

      int totalParents = 0;
      try {
        final parentsList = await _pb
            .collection('users')
            .getList(page: 1, perPage: 1, filter: "role = 'orang_tua'");
        totalParents = parentsList.totalItems;
      } catch (_) {}

      int totalConsultations = 0;
      try {
        final consultationsList = await _pb
            .collection('parent_consultations')
            .getList(page: 1, perPage: 1);
        totalConsultations = consultationsList.totalItems;
      } catch (_) {}

      int pendingRequests = 0;
      try {
        final reqList = await _pb
            .collection('consultation_requests')
            .getList(page: 1, perPage: 1, filter: "status = 'pending'");
        pendingRequests = reqList.totalItems;
        final allReqList = await _pb
            .collection('consultation_requests')
            .getList(page: 1, perPage: 1);
        totalConsultations += allReqList.totalItems;
      } catch (_) {}

      return DashboardAnalyticsSummary(
        totalStudents: totalStudents,
        totalCases: totalCases,
        completedCases: completedCases,
        activeCases: activeCases,
        totalSessions: sessionsList.totalItems,
        totalParents: totalParents,
        totalConsultations: totalConsultations,
        pendingRequests: pendingRequests,
        byGrade: byGrade,
        topStudents: topStudents,
      );
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// Ambil ringkasan analitik eksekutif khusus Kepala Sekolah dengan dukungan filter Range Tanggal dan Tahun.
  Future<KepsekAnalyticsData> getKepsekAnalytics({
    KepsekFilterMode filterMode = KepsekFilterMode.dateRange,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? selectedDate,
    int? selectedYear,
    bool isSemester = false,
    DateTime? referenceDate,
  }) async {
    try {
      int totalStudents = 0;
      try {
        final studentsList =
            await _pb.collection('students').getList(page: 1, perPage: 1);
        totalStudents = studentsList.totalItems;
      } catch (_) {}

      List<CaseRecordModel> allCases = [];
      try {
        final caseRecs = await _pb.collection('cases').getFullList(
              sort: '-created',
              expand: 'student,category,counselor',
            );
        allCases = caseRecs.map(CaseRecordModel.fromRecord).toList();
      } catch (_) {}

      final ref = referenceDate ?? _resolveReferenceDate(allCases);

      DateTime curStart;
      DateTime curEnd;
      DateTime prevStart;
      DateTime prevEnd;
      String periodName;
      String badgeSuffix;

      if (filterMode == KepsekFilterMode.dateRange && !isSemester) {
        // Mode Range Tanggal
        final start = startDate ?? (selectedDate ?? DateTime(ref.year, ref.month, 1));
        final end = endDate ?? (selectedDate ?? ref);

        curStart = DateTime(start.year, start.month, start.day, 0, 0, 0);
        curEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);

        final days = end.difference(start).inDays + 1;
        prevEnd = curStart.subtract(const Duration(seconds: 1));
        prevStart = DateTime(prevEnd.year, prevEnd.month, prevEnd.day, 0, 0, 0)
            .subtract(Duration(days: days - 1));

        if (start.year == end.year && start.month == end.month && start.day == end.day) {
          periodName = PbClient.formatDateFull(start);
          badgeSuffix = 'hr ini';
        } else {
          periodName = '${PbClient.formatDateShort(start)} – ${PbClient.formatDateShort(end)}';
          badgeSuffix = 'periode ini';
        }
      } else if (filterMode == KepsekFilterMode.date && !isSemester) {
        // Mode Single Date
        final target = selectedDate ?? ref;
        curStart = DateTime(target.year, target.month, target.day, 0, 0, 0);
        curEnd = DateTime(target.year, target.month, target.day, 23, 59, 59);

        final yest = target.subtract(const Duration(days: 1));
        prevStart = DateTime(yest.year, yest.month, yest.day, 0, 0, 0);
        prevEnd = DateTime(yest.year, yest.month, yest.day, 23, 59, 59);

        periodName = PbClient.formatDateFull(target);
        badgeSuffix = 'hr ini';
      } else if (filterMode == KepsekFilterMode.year && !isSemester) {
        // Mode Tahun
        final yr = selectedYear ?? (selectedDate?.year ?? ref.year);
        curStart = DateTime(yr, 1, 1, 0, 0, 0);
        curEnd = DateTime(yr, 12, 31, 23, 59, 59);

        prevStart = DateTime(yr - 1, 1, 1, 0, 0, 0);
        prevEnd = DateTime(yr - 1, 12, 31, 23, 59, 59);

        periodName = 'Tahun $yr';
        badgeSuffix = 'thn ini';
      } else {
        // Fallback Semester
        if (ref.month >= 7) {
          curStart = DateTime(ref.year, 7, 1);
          curEnd = DateTime(ref.year, 12, 31, 23, 59, 59);
          prevStart = DateTime(ref.year, 1, 1);
          prevEnd = DateTime(ref.year, 6, 30, 23, 59, 59);
          periodName = 'Semester Ganjil ${ref.year}/${ref.year + 1}';
        } else {
          curStart = DateTime(ref.year, 1, 1);
          curEnd = DateTime(ref.year, 6, 30, 23, 59, 59);
          prevStart = DateTime(ref.year - 1, 7, 1);
          prevEnd = DateTime(ref.year - 1, 12, 31, 23, 59, 59);
          periodName = 'Semester Genap ${ref.year - 1}/${ref.year}';
        }
        badgeSuffix = 'smt ini';
      }

      // Saring kasus berdasarkan periode aktif dan periode sebelumnya
      final periodCases = allCases.where((c) {
        final d = c.resolvedIncidentDate;
        return !d.isBefore(curStart) && !d.isAfter(curEnd);
      }).toList();

      final prevCases = allCases.where((c) {
        final d = c.resolvedIncidentDate;
        return !d.isBefore(prevStart) && !d.isAfter(prevEnd);
      }).toList();

      final totalCases = periodCases.length;
      final completedCases = periodCases.where((c) => c.isCompleted).length;

      final double completionRate = totalCases > 0
          ? ((completedCases / totalCases) * 100.0)
          : 100.0;
      final String completionBadgeText =
          '${completionRate.round()}% Tuntas';

      // Perhitungan perubahan kasus vs periode sebelumnya
      final int curCount = periodCases.length;
      final int prevCount = prevCases.length;
      double caseChangePercentage = 0.0;
      if (prevCount > 0) {
        caseChangePercentage = ((curCount - prevCount) / prevCount) * 100.0;
      } else if (curCount > 0) {
        caseChangePercentage = 100.0;
      }

      final bool isCaseDecreased = caseChangePercentage < 0;
      final String sign = caseChangePercentage > 0 ? '+' : '';
      String caseBadgeText;
      if (totalCases == 0) {
        caseBadgeText = '0 Kasus';
      } else if (prevCount > 0) {
        caseBadgeText = '$sign${caseChangePercentage.round()}% $badgeSuffix';
      } else {
        caseBadgeText = '$totalCases Kasus';
      }

      // Tren 6 bulan terakhir
      final targetRefDate = endDate ?? (selectedDate ?? ref);
      final List<MonthlyCaseTrend> rawMonthly = [];
      int maxBarCount = 0;
      for (int i = 5; i >= 0; i--) {
        final mDt = DateTime(targetRefDate.year, targetRefDate.month - i, 1);
        final mStart = DateTime(mDt.year, mDt.month, 1);
        final mEnd = DateTime(mDt.year, mDt.month + 1, 0, 23, 59, 59);
        final count = allCases.where((c) {
          final d = c.resolvedIncidentDate;
          return !d.isBefore(mStart) && !d.isAfter(mEnd);
        }).length;
        if (count > maxBarCount) maxBarCount = count;
        rawMonthly.add(MonthlyCaseTrend(
          month: _monthNamesShort[mDt.month - 1],
          count: count,
          fillHeight: 0.0,
          isCurrent: i == 0,
        ));
      }

      // Visual grafik proporsional murni berdasarkan data riil dari database
      final List<MonthlyCaseTrend> monthlyBars = [];
      final effectiveMax = maxBarCount > 0 ? maxBarCount : 1;
      for (final m in rawMonthly) {
        final h = m.count > 0
            ? ((m.count / effectiveMax) * 76.0).clamp(14.0, 76.0)
            : 6.0;
        monthlyBars.add(MonthlyCaseTrend(
          month: m.month,
          count: m.count,
          fillHeight: h,
          isCurrent: m.isCurrent,
        ));
      }

      final trendPeriodSubtitle =
          'Periode ${monthlyBars.first.month} – ${monthlyBars.last.month} ${targetRefDate.year}';

      // Ringkasan tren teks
      String trendSummaryText;
      if (filterMode == KepsekFilterMode.year && !isSemester) {
        final yr = selectedYear ?? targetRefDate.year;
        if (isCaseDecreased) {
          trendSummaryText =
              'Kasus pelanggaran turun ${caseChangePercentage.abs().round()}% di tahun $yr.';
        } else if (caseChangePercentage > 0) {
          trendSummaryText =
              'Kasus pelanggaran naik ${caseChangePercentage.round()}% di tahun $yr.';
        } else {
          trendSummaryText =
              'Total $totalCases kasus pelanggaran tercatat sepanjang tahun $yr.';
        }
      } else {
        if (totalCases > 0) {
          trendSummaryText =
              'Tercatat $totalCases kasus pelanggaran pada $periodName.';
        } else {
          trendSummaryText =
              'Tidak ada laporan kasus pelanggaran pada $periodName.';
        }
      }

      // Sebaran Kelas — dihitung secara konsisten dari periodCases
      int c7 = 0, c8 = 0, c9 = 0;
      int comp7 = 0, comp8 = 0, comp9 = 0;
      for (final c in periodCases) {
        final cls = c.studentClass.toUpperCase();
        if (cls.contains('VII') && !cls.contains('VIII')) {
          c7++;
          if (c.isCompleted) comp7++;
        } else if (cls.contains('VIII')) {
          c8++;
          if (c.isCompleted) comp8++;
        } else if (cls.contains('IX')) {
          c9++;
          if (c.isCompleted) comp9++;
        } else {
          c7++;
          if (c.isCompleted) comp7++;
        }
      }

      final totalActive = periodCases.length;
      final maxGradeCount = [c7, c8, c9].reduce((a, b) => a > b ? a : b);
      final gradeDistributions = [
        GradeCaseSummary(
          gradeLevel: 'Kelas VII',
          totalCases: c7,
          completedCases: comp7,
          percentage: totalActive > 0 ? (c7 / totalActive * 100.0) : 0.0,
          progressFraction: maxGradeCount > 0 ? (c7 / maxGradeCount) : 0.0,
        ),
        GradeCaseSummary(
          gradeLevel: 'Kelas VIII',
          totalCases: c8,
          completedCases: comp8,
          percentage: totalActive > 0 ? (c8 / totalActive * 100.0) : 0.0,
          progressFraction: maxGradeCount > 0 ? (c8 / maxGradeCount) : 0.0,
        ),
        GradeCaseSummary(
          gradeLevel: 'Kelas IX',
          totalCases: c9,
          completedCases: comp9,
          percentage: totalActive > 0 ? (c9 / totalActive * 100.0) : 0.0,
          progressFraction: maxGradeCount > 0 ? (c9 / maxGradeCount) : 0.0,
        ),
      ];

      // Sebaran Kategori Kasus
      final catCountMap = <String, int>{};
      for (final c in periodCases) {
        final cat = c.caseCategory.isNotEmpty ? c.caseCategory : 'Kedisiplinan';
        catCountMap[cat] = (catCountMap[cat] ?? 0) + 1;
      }
      final sortedCats = catCountMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final maxCatCount = sortedCats.isNotEmpty ? sortedCats.first.value : 1;
      final categoryDistributions = sortedCats.map((e) {
        return CategoryCaseSummary(
          categoryName: e.key,
          caseCount: e.value,
          percentage: totalActive > 0 ? (e.value / totalActive * 100.0) : 0.0,
          progressFraction: maxCatCount > 0 ? (e.value / maxCatCount) : 0.0,
        );
      }).toList();

      // Top Siswa
      final studentStatMap = <String, _StudentStat>{};
      for (final c in periodCases) {
        final key = c.studentNisn.isNotEmpty && c.studentNisn != '-'
            ? c.studentNisn
            : c.studentName;
        if (!studentStatMap.containsKey(key)) {
          studentStatMap[key] = _StudentStat(
            id: c.studentId,
            name: c.studentName,
            studentClass: c.studentClass,
            nisn: c.studentNisn,
          );
        }
        studentStatMap[key]!.caseCount += 1;
        studentStatMap[key]!.totalPoints += c.violationPoints;
      }
      final sortedStudents = studentStatMap.values.toList()
        ..sort((a, b) {
          final cmp = b.caseCount.compareTo(a.caseCount);
          if (cmp != 0) return cmp;
          return b.totalPoints.compareTo(a.totalPoints);
        });
      final topStudents = sortedStudents.take(5).map((s) {
        return TopStudentCaseRank(
          studentId: s.id,
          studentName: s.name,
          studentClass: s.studentClass,
          studentNisn: s.nisn,
          caseCount: s.caseCount,
          totalPoints: s.totalPoints,
        );
      }).toList();

      return KepsekAnalyticsData(
        totalStudents: totalStudents,
        totalCases: totalCases,
        completedCases: completedCases,
        completionRate: completionRate,
        completionBadgeText: completionBadgeText,
        caseChangePercentage: caseChangePercentage,
        caseBadgeText: caseBadgeText,
        isCaseDecreased: isCaseDecreased,
        trendSummaryText: trendSummaryText,
        trendPeriodSubtitle: trendPeriodSubtitle,
        monthlyBars: monthlyBars,
        gradeDistributions: gradeDistributions,
        categoryDistributions: categoryDistributions,
        topStudents: topStudents,
        periodName: periodName,
      );
    } catch (e) {
      throw AppException.from(e);
    }
  }

  DateTime _resolveReferenceDate(List<CaseRecordModel> cases) {
    final now = DateTime.now();
    final hasCurrentMonthCase = cases.any(
      (c) =>
          c.resolvedIncidentDate.year == now.year &&
          c.resolvedIncidentDate.month == now.month,
    );
    if (hasCurrentMonthCase) return now;

    if (cases.isNotEmpty) {
      DateTime latest = cases.first.resolvedIncidentDate;
      for (final c in cases) {
        if (c.resolvedIncidentDate.isAfter(latest)) {
          latest = c.resolvedIncidentDate;
        }
      }
      return latest;
    }
    return now;
  }
}

class _StudentStat {
  final String id;
  final String name;
  final String studentClass;
  final String nisn;
  int caseCount = 0;
  int totalPoints = 0;

  _StudentStat({
    required this.id,
    required this.name,
    required this.studentClass,
    required this.nisn,
  });
}
