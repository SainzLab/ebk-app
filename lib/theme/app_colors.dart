import 'package:flutter/material.dart';

/// Sumber kebenaran mutlak (Single Source of Truth) untuk palet warna
/// yang diekstrak langsung dari `ebk_design.json` (E-BK SMPN 1 Pabuaran).
class AppColors {
  AppColors._();

  // ===========================================================================
  // 01. Core Brand & Surface Colors (Paint Styles S:1 - S:8)
  // ===========================================================================

  /// S:1 - E-BK SMPN 1 Pabuaran/Primary Navy (#1B3B7B)
  /// Identitas SMP & Tombol Utama
  static const Color primaryNavy = Color(0xFF1B3B7B);

  /// S:2 - E-BK SMPN 1 Pabuaran/Primary Dark (#122856)
  /// Navy Pressed / Aksen Gelap & Status Aktif
  static const Color primaryDark = Color(0xFF122856);
  static const Color navyPressed = Color(0xFF122856);

  /// S:3 - E-BK SMPN 1 Pabuaran/Primary Tint (#EBF2FF)
  /// Soft Navy Tint / Latar Ikon & Pill Informasi
  static const Color primaryTint = Color(0xFFEBF2FF);
  static const Color softNavyTint = Color(0xFFEBF2FF);

  /// S:4 - E-BK SMPN 1 Pabuaran/Pure White (#FFFFFF)
  /// Kartu Utama & Kontainer
  static const Color pureWhite = Color(0xFFFFFFFF);

  /// S:5 - E-BK SMPN 1 Pabuaran/Canvas Light Gray (#F4F7FB)
  /// Latar Layar Mobile Bersih
  static const Color canvasLightGray = Color(0xFFF4F7FB);

  /// S:6 - E-BK SMPN 1 Pabuaran/Input Surface Gray (#F8FAFC)
  /// Isian Input Field Default & Sub-Container
  static const Color inputSurfaceGray = Color(0xFFF8FAFC);

  /// S:7 - E-BK SMPN 1 Pabuaran/Border Neutral (#E2E8F0)
  /// Garis Tepi Halus (1px)
  static const Color borderNeutral = Color(0xFFE2E8F0);

  /// S:8 - E-BK SMPN 1 Pabuaran/Text Primary (#0F172A)
  /// Judul & Label Kontras Tinggi
  static const Color textPrimary = Color(0xFF0F172A);

  // ===========================================================================
  // 02. Text & Neutral Hierarchy Tokens
  // ===========================================================================

  /// Subteks & Hint (#64748B)
  static const Color textMuted = Color(0xFF64748B);

  /// Teks Sekunder / Isi Catatan (#475569)
  static const Color textSecondary = Color(0xFF475569);

  /// Teks Paragraf Kontras Sedang-Tinggi (#334155)
  static const Color textBody = Color(0xFF334155);

  /// Placeholder Input & Ikon Non-Aktif (#94A3B8)
  static const Color textPlaceholder = Color(0xFF94A3B8);

  /// Garis Tepi Kartu Form Halus (#EEF2F6)
  static const Color borderSoft = Color(0xFFEEF2F6);

  /// Garis Tepi Sekunder & Home Indicator (#CBD5E1)
  static const Color borderMuted = Color(0xFFCBD5E1);

  /// Divider Tabel & Baris (#F1F5F9)
  static const Color dividerSubtle = Color(0xFFF1F5F9);

  // ===========================================================================
  // 03. Blue Accent & Chart Tokens
  // ===========================================================================

  /// Aksen Biru & Progress Kelas VII (#3B82F6)
  static const Color blueAccent = Color(0xFF3B82F6);

  /// Biru Muda Bar Chart & Teks Pill Gelap (#93C5FD)
  static const Color blueLight = Color(0xFF93C5FD);

  /// Garis Tepi Avatar & Badge Biru (#BFDBFE)
  static const Color borderBlueAccent = Color(0xFFBFDBFE);

  /// Teks Sub-Kartu Navy & Garis Tepi Info (#DBEAFE)
  static const Color borderBlueTint = Color(0xFFDBEAFE);

  // ===========================================================================
  // 04. Semantic Status Colors (Success, Warning, Error/Danger)
  // ===========================================================================

  /// Status Selesai / Toast Sukses
  static const Color successSurface = Color(0xFFF0FDF4);
  static const Color successBg = Color(0xFFDCFCE7);
  static const Color successBadgeBg = Color(0xFFBBF7D0);
  static const Color successBorder = Color(0xFF86EFAC);
  static const Color successDot = Color(0xFF16A34A);
  static const Color successText = Color(0xFF15803D);
  static const Color successDarkText = Color(0xFF14532D);

  /// Status Dalam Proses / Peringatan Sistem (Amber)
  static const Color warningSurface = Color(0xFFFFFBEB);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color warningBorder = Color(0xFFFDE68A);
  static const Color warningAccent = Color(0xFFF59E0B);
  static const Color warningIcon = Color(0xFFD97706);
  static const Color warningText = Color(0xFFB45309);

  /// Status Error / Hapus / Frekuensi Tinggi (Red)
  static const Color errorSurface = Color(0xFFFEF2F2);
  static const Color errorBg = Color(0xFFFEE2E2);
  static const Color errorLightBg = Color(0xFFFEE2E2);
  static const Color errorBadgeBg = Color(0xFFFECACA);
  static const Color errorBorder = Color(0xFFFCA5A5);
  static const Color errorPrimary = Color(0xFFDC2626);
  static const Color errorClose = Color(0xFFB91C1C);
  static const Color errorIcon = Color(0xFF991B1B);
  static const Color errorDarkText = Color(0xFF7F1D1D);

  /// Status Info / Pengajuan Wali (Light Blue)
  static const Color infoSurface = Color(0xFFEFF6FF);
  static const Color infoBg = Color(0xFFDBEAFE);
  static const Color infoBorder = Color(0xFFBFDBFE);
  static const Color infoText = Color(0xFF1D4ED8);

  // ===========================================================================
  // 05. Skeleton, Scrim & Dark Mode Tokens
  // ===========================================================================

  /// Skeleton Shimmer Stops (#DCE3EE -> #EEF3F9 -> #DCE3EE)
  static const Color skeletonBase = Color(0xFFDCE3EE);
  static const Color skeletonHighlight = Color(0xFFEEF3F9);
  static const Color skeletonCardBorder = Color(0xFFE8EEF5);
  static const Color skeletonSubcardBorder = Color(0xFFEEF2F7);

  /// Overlay Hitam Semi-Transparan (Opacity 40% - Gambar 15)
  static const Color overlayBackdrop = Color(0x66000000);

  /// Backdrop Gelap Transparan Modal (Opacity 50% - Gambar 17 & 18)
  static const Color modalBackdrop = Color(0x80000000);

  /// Variabel Dark Mode (01 • Design System)
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);

  /// Shadow Dasar Kartu & Navigasi (r:15, g:23, b:42 / #0F172A)
  static const Color shadowBase = Color(0xFF0F172A);
}
