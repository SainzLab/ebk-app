import 'package:flutter_test/flutter_test.dart';
import 'package:ebkapp/models/case_model.dart';
import 'package:ebkapp/repositories/analytics_repository.dart';

void main() {
  group('Kepsek Analytics Model & Calculation Tests', () {
    test('KepsekAnalyticsData instantiates with valid metrics', () {
      const data = KepsekAnalyticsData(
        totalStudents: 640,
        totalCases: 24,
        completedCases: 19,
        completionRate: 79.2,
        completionBadgeText: '79% Tuntas',
        caseChangePercentage: -17.0,
        caseBadgeText: '-17% bln ini',
        isCaseDecreased: true,
        trendSummaryText: 'Kasus pelanggaran turun 17% di bulan November.',
        trendPeriodSubtitle: 'Periode Jun – Nov 2026',
        monthlyBars: [
          MonthlyCaseTrend(month: 'Jun', count: 16, fillHeight: 36.0),
          MonthlyCaseTrend(month: 'Nov', count: 24, fillHeight: 54.0, isCurrent: true),
        ],
        gradeDistributions: [
          GradeCaseSummary(
            gradeLevel: 'Kelas VII',
            totalCases: 5,
            completedCases: 4,
            percentage: 21.0,
            progressFraction: 0.54,
          ),
        ],
        categoryDistributions: [
          CategoryCaseSummary(
            categoryName: 'Kedisiplinan',
            caseCount: 11,
            percentage: 45.8,
            progressFraction: 1.0,
          ),
        ],
        topStudents: [
          TopStudentCaseRank(
            studentId: 'std1',
            studentName: 'Bagas Pratama',
            studentClass: 'Kelas VIII-B',
            studentNisn: '0112839401',
            caseCount: 5,
            totalPoints: 50,
          ),
        ],
        periodName: 'Bulan Ini (November 2026)',
      );

      expect(data.totalStudents, 640);
      expect(data.totalCases, 24);
      expect(data.completedCases, 19);
      expect(data.completionBadgeText, '79% Tuntas');
      expect(data.isCaseDecreased, isTrue);
      expect(data.caseBadgeText, '-17% bln ini');
      expect(data.monthlyBars.length, 2);
      expect(data.monthlyBars.last.isCurrent, isTrue);
      expect(data.gradeDistributions.first.gradeLevel, 'Kelas VII');
      expect(data.categoryDistributions.first.categoryName, 'Kedisiplinan');
      expect(data.topStudents.first.studentName, 'Bagas Pratama');
    });

    test('CaseRecordModel parseIncidentDateTime handles various formats', () {
      final date1 = CaseRecordModel.parseIncidentDateTime('Kamis, 05 Nov 2026 • 10:15 WIB');
      expect(date1.year, 2026);
      expect(date1.month, 11);
      expect(date1.day, 5);
      expect(date1.hour, 10);
      expect(date1.minute, 15);

      final date2 = CaseRecordModel.parseIncidentDateTime('Senin, 19 Okt 2026 • 07:15 WIB');
      expect(date2.year, 2026);
      expect(date2.month, 10);
      expect(date2.day, 19);
      expect(date2.hour, 7);
      expect(date2.minute, 15);

      final isoDate = CaseRecordModel.parseIncidentDateTime('2026-11-06T14:30:00.000Z');
      expect(isoDate.year, 2026);
      expect(isoDate.month, 11);
      expect(isoDate.day, 6);
    });
  });
}
