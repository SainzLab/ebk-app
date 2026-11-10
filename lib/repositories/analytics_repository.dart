import 'package:pocketbase/pocketbase.dart';
import '../core/app_exception.dart';
import '../core/pb_client.dart';

class GradeCaseSummary {
  final String gradeLevel;
  final int totalCases;
  final int completedCases;

  const GradeCaseSummary({
    required this.gradeLevel,
    required this.totalCases,
    required this.completedCases,
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

class AnalyticsRepository {
  AnalyticsRepository._();
  static final AnalyticsRepository instance = AnalyticsRepository._();

  PocketBase get _pb => PbClient.instance;

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
}
