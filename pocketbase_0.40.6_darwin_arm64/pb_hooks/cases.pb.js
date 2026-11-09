/// <reference path="../pb_data/types.d.ts" />

// Auto-generate kode kasus (#BK-YYYY-NNN) bila kosong saat record dibuat
onRecordCreate((e) => {
  const code = e.record.getString("code");
  if (!code || code.trim() === "") {
    const year = new Date().getFullYear();
    const prefix = `#BK-${year}-`;
    let maxSeq = 0;
    try {
      const existing = e.app.findRecordsByFilter(
        "cases",
        `code ~ {:prefix}`,
        "-code",
        1,
        0,
        { prefix: prefix }
      );
      if (existing && existing.length > 0 && existing[0]) {
        const lastCode = existing[0].getString("code");
        const parts = lastCode.split("-");
        if (parts.length >= 3) {
          const parsed = parseInt(parts[2], 10);
          if (!isNaN(parsed)) {
            maxSeq = parsed;
          }
        }
      }
    } catch (_) {}

    const nextSeq = String(maxSeq + 1).padStart(3, "0");
    e.record.set("code", `${prefix}${nextSeq}`);
  }
  e.next();
}, "cases");

// Helper kalkulasi ulang total_points siswa di dalam hook
onRecordAfterCreateSuccess((e) => {
  const studentId = e.record.getString("student");
  if (studentId) {
    try {
      const studentRec = e.app.findRecordById("students", studentId);
      const allCases = e.app.findRecordsByFilter(
        "cases",
        "student = {:sid}",
        "",
        500,
        0,
        { sid: studentId }
      );
      let total = 0;
      for (const c of allCases) {
        if (c) total += c.getInt("points");
      }
      studentRec.set("total_points", total);
      e.app.save(studentRec);
    } catch (_) {}
  }
  e.next();
}, "cases");

onRecordAfterUpdateSuccess((e) => {
  const studentId = e.record.getString("student");
  if (studentId) {
    try {
      const studentRec = e.app.findRecordById("students", studentId);
      const allCases = e.app.findRecordsByFilter(
        "cases",
        "student = {:sid}",
        "",
        500,
        0,
        { sid: studentId }
      );
      let total = 0;
      for (const c of allCases) {
        if (c) total += c.getInt("points");
      }
      studentRec.set("total_points", total);
      e.app.save(studentRec);
    } catch (_) {}
  }
  e.next();
}, "cases");

onRecordAfterDeleteSuccess((e) => {
  const studentId = e.record.getString("student");
  if (studentId) {
    try {
      const studentRec = e.app.findRecordById("students", studentId);
      const allCases = e.app.findRecordsByFilter(
        "cases",
        "student = {:sid}",
        "",
        500,
        0,
        { sid: studentId }
      );
      let total = 0;
      for (const c of allCases) {
        if (c) total += c.getInt("points");
      }
      studentRec.set("total_points", total);
      e.app.save(studentRec);
    } catch (_) {}
  }
  e.next();
}, "cases");
