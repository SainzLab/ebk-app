/// <reference path="../pb_data/types.d.ts" />

migrate((app) => {
  // 1. Update collection `users`
  const users = app.findCollectionByNameOrId("users");

  users.fields.add(new TextField({
    name: "username",
    required: false,
    presentable: true,
  }));
  users.fields.add(new SelectField({
    name: "role",
    required: true,
    maxSelect: 1,
    values: ["guru_bk", "orang_tua", "kepala_sekolah"],
  }));
  users.fields.add(new TextField({
    name: "phone",
    required: false,
  }));
  users.fields.add(new TextField({
    name: "nip",
    required: false,
  }));
  users.fields.add(new TextField({
    name: "position",
    required: false,
  }));
  users.fields.add(new BoolField({
    name: "is_active",
  }));
  users.fields.add(new BoolField({
    name: "notify_email",
  }));
  users.fields.add(new BoolField({
    name: "notify_system",
  }));

  users.passwordAuth.enabled = true;
  users.passwordAuth.identityFields = ["email", "username"];
  users.indexes.push(
    "CREATE UNIQUE INDEX `idx_username__pb_users_auth_` ON `users` (`username`) WHERE `username` != ''"
  );

  // Guru BK & Kepsek tetap bisa login walau lupa centang is_active saat buat manual di Admin UI;
  // akun orang_tua wajib is_active = true.
  users.authRule = "is_active = true || role = 'guru_bk' || role = 'kepala_sekolah'";
  users.manageRule = "@request.auth.role = 'guru_bk'";
  users.listRule = "id = @request.auth.id || @request.auth.role = 'guru_bk' || @request.auth.role = 'kepala_sekolah'";
  users.viewRule = "id = @request.auth.id || @request.auth.role = 'guru_bk' || @request.auth.role = 'kepala_sekolah'";
  users.createRule = "@request.auth.role = 'guru_bk'";
  users.updateRule = "id = @request.auth.id || @request.auth.role = 'guru_bk'";
  users.deleteRule = "@request.auth.role = 'guru_bk'";

  app.save(users);

  // 2. Collection `students`
  const students = new Collection({
    type: "base",
    name: "students",
    listRule: "@request.auth.role = 'guru_bk' || @request.auth.role = 'kepala_sekolah' || guardian = @request.auth.id",
    viewRule: "@request.auth.role = 'guru_bk' || @request.auth.role = 'kepala_sekolah' || guardian = @request.auth.id",
    createRule: "@request.auth.role = 'guru_bk'",
    updateRule: "@request.auth.role = 'guru_bk'",
    deleteRule: "@request.auth.role = 'guru_bk'",
    fields: [
      { name: "name", type: "text", required: true, presentable: true },
      { name: "nis", type: "text", required: false },
      { name: "nisn", type: "text", required: true },
      { name: "class_name", type: "text", required: true },
      {
        name: "grade_level",
        type: "select",
        required: true,
        maxSelect: 1,
        values: ["Kelas VII", "Kelas VIII", "Kelas IX"],
      },
      {
        name: "gender",
        type: "select",
        required: true,
        maxSelect: 1,
        values: ["Laki-laki", "Perempuan"],
      },
      { name: "address", type: "text", required: false },
      {
        name: "guardian",
        type: "relation",
        collectionId: users.id,
        cascadeDelete: false,
        maxSelect: 1,
        required: false,
      },
      { name: "guardian_name", type: "text", required: false },
      { name: "guardian_relation", type: "text", required: false },
      { name: "guardian_phone", type: "text", required: false },
      { name: "total_points", type: "number", required: false, min: 0 },
      { name: "created", type: "autodate", onCreate: true, onUpdate: false },
      { name: "updated", type: "autodate", onCreate: true, onUpdate: true },
    ],
    indexes: [
      "CREATE UNIQUE INDEX `idx_students_nisn` ON `students` (`nisn`)",
      "CREATE INDEX `idx_students_class_name` ON `students` (`class_name`)",
      "CREATE INDEX `idx_students_guardian` ON `students` (`guardian`)",
    ],
  });
  app.save(students);

  // 3. Collection `case_categories`
  const caseCategories = new Collection({
    type: "base",
    name: "case_categories",
    listRule: "@request.auth.id != ''",
    viewRule: "@request.auth.id != ''",
    createRule: "@request.auth.role = 'guru_bk'",
    updateRule: "@request.auth.role = 'guru_bk'",
    deleteRule: "@request.auth.role = 'guru_bk'",
    fields: [
      { name: "name", type: "text", required: true, presentable: true },
      { name: "default_points", type: "number", required: false, min: 0 },
      { name: "default_title", type: "text", required: false },
      { name: "default_location", type: "text", required: false },
      { name: "created", type: "autodate", onCreate: true, onUpdate: false },
      { name: "updated", type: "autodate", onCreate: true, onUpdate: true },
    ],
    indexes: [
      "CREATE UNIQUE INDEX `idx_case_categories_name` ON `case_categories` (`name`)",
    ],
  });
  app.save(caseCategories);

  // 4. Collection `cases`
  const cases = new Collection({
    type: "base",
    name: "cases",
    listRule: "@request.auth.role = 'guru_bk' || @request.auth.role = 'kepala_sekolah' || student.guardian = @request.auth.id",
    viewRule: "@request.auth.role = 'guru_bk' || @request.auth.role = 'kepala_sekolah' || student.guardian = @request.auth.id",
    createRule: "@request.auth.role = 'guru_bk'",
    updateRule: "@request.auth.role = 'guru_bk'",
    deleteRule: "@request.auth.role = 'guru_bk'",
    fields: [
      { name: "code", type: "text", required: false, presentable: true },
      {
        name: "student",
        type: "relation",
        collectionId: students.id,
        cascadeDelete: true,
        maxSelect: 1,
        required: true,
      },
      {
        name: "category",
        type: "relation",
        collectionId: caseCategories.id,
        cascadeDelete: false,
        maxSelect: 1,
        required: false,
      },
      { name: "category_name", type: "text", required: true },
      { name: "title", type: "text", required: true },
      { name: "incident_time", type: "date", required: false },
      { name: "incident_time_text", type: "text", required: false },
      { name: "location", type: "text", required: false },
      { name: "chronology", type: "text", required: false },
      { name: "handling", type: "text", required: false },
      { name: "handling_date", type: "date", required: false },
      { name: "handling_date_text", type: "text", required: false },
      {
        name: "counselor",
        type: "relation",
        collectionId: users.id,
        cascadeDelete: false,
        maxSelect: 1,
        required: false,
      },
      { name: "counselor_name", type: "text", required: false },
      { name: "is_completed", type: "bool" },
      { name: "points", type: "number", required: false, min: 0 },
      { name: "created", type: "autodate", onCreate: true, onUpdate: false },
      { name: "updated", type: "autodate", onCreate: true, onUpdate: true },
    ],
    indexes: [
      "CREATE UNIQUE INDEX `idx_cases_code` ON `cases` (`code`) WHERE `code` != ''",
      "CREATE INDEX `idx_cases_student` ON `cases` (`student`)",
      "CREATE INDEX `idx_cases_incident_time` ON `cases` (`incident_time`)",
    ],
  });
  app.save(cases);

  // 5. Collection `counseling_sessions`
  const counselingSessions = new Collection({
    type: "base",
    name: "counseling_sessions",
    listRule: "@request.auth.role = 'guru_bk' || @request.auth.role = 'kepala_sekolah' || student.guardian = @request.auth.id",
    viewRule: "@request.auth.role = 'guru_bk' || @request.auth.role = 'kepala_sekolah' || student.guardian = @request.auth.id",
    createRule: "@request.auth.role = 'guru_bk'",
    updateRule: "@request.auth.role = 'guru_bk'",
    deleteRule: "@request.auth.role = 'guru_bk'",
    fields: [
      {
        name: "student",
        type: "relation",
        collectionId: students.id,
        cascadeDelete: true,
        maxSelect: 1,
        required: true,
      },
      {
        name: "counselor",
        type: "relation",
        collectionId: users.id,
        cascadeDelete: false,
        maxSelect: 1,
        required: false,
      },
      { name: "session_date", type: "date", required: false },
      { name: "date_str", type: "text", required: false },
      { name: "day_index", type: "number", required: false, min: 0, max: 6 },
      { name: "time_range", type: "text", required: true },
      {
        name: "counseling_type",
        type: "select",
        required: true,
        maxSelect: 1,
        values: [
          "Individu",
          "Kelompok",
          "Belajar / Akademik",
          "Karir",
          "Sosial / Perilaku",
        ],
      },
      { name: "topic", type: "text", required: true, presentable: true },
      { name: "result_notes", type: "text", required: false },
      { name: "follow_up_plan", type: "text", required: false },
      { name: "is_completed", type: "bool" },
      { name: "created", type: "autodate", onCreate: true, onUpdate: false },
      { name: "updated", type: "autodate", onCreate: true, onUpdate: true },
    ],
    indexes: [
      "CREATE INDEX `idx_counseling_student` ON `counseling_sessions` (`student`)",
      "CREATE INDEX `idx_counseling_date` ON `counseling_sessions` (`session_date`)",
    ],
  });
  app.save(counselingSessions);

  // 6. Collection `parent_consultations`
  const parentConsultations = new Collection({
    type: "base",
    name: "parent_consultations",
    listRule: "@request.auth.role = 'guru_bk' || @request.auth.role = 'kepala_sekolah' || parent = @request.auth.id || student.guardian = @request.auth.id",
    viewRule: "@request.auth.role = 'guru_bk' || @request.auth.role = 'kepala_sekolah' || parent = @request.auth.id || student.guardian = @request.auth.id",
    createRule: "@request.auth.role = 'guru_bk'",
    updateRule: "@request.auth.role = 'guru_bk'",
    deleteRule: "@request.auth.role = 'guru_bk'",
    fields: [
      {
        name: "parent",
        type: "relation",
        collectionId: users.id,
        cascadeDelete: false,
        maxSelect: 1,
        required: false,
      },
      { name: "parent_name", type: "text", required: true },
      {
        name: "student",
        type: "relation",
        collectionId: students.id,
        cascadeDelete: true,
        maxSelect: 1,
        required: true,
      },
      {
        name: "counselor",
        type: "relation",
        collectionId: users.id,
        cascadeDelete: false,
        maxSelect: 1,
        required: false,
      },
      { name: "held_at", type: "date", required: false },
      { name: "date_time_text", type: "text", required: true },
      {
        name: "consultation_method",
        type: "select",
        required: true,
        maxSelect: 1,
        values: [
          "Tatap Muka di Ruang BK",
          "Panggilan Telepon / WA",
          "Home Visit / Kunjungan",
        ],
      },
      { name: "topic", type: "text", required: true, presentable: true },
      { name: "discussion_summary", type: "text", required: false },
      { name: "follow_up_plan", type: "text", required: false },
      { name: "is_completed", type: "bool" },
      { name: "created", type: "autodate", onCreate: true, onUpdate: false },
      { name: "updated", type: "autodate", onCreate: true, onUpdate: true },
    ],
    indexes: [
      "CREATE INDEX `idx_parent_consultations_student` ON `parent_consultations` (`student`)",
      "CREATE INDEX `idx_parent_consultations_parent` ON `parent_consultations` (`parent`)",
    ],
  });
  app.save(parentConsultations);

  // 7. Collection `consultation_requests` (pengajuan dari orang tua)
  const consultationRequests = new Collection({
    type: "base",
    name: "consultation_requests",
    listRule: "@request.auth.role = 'guru_bk' || @request.auth.role = 'kepala_sekolah' || parent = @request.auth.id",
    viewRule: "@request.auth.role = 'guru_bk' || @request.auth.role = 'kepala_sekolah' || parent = @request.auth.id",
    createRule: "@request.auth.id != ''",
    updateRule: "@request.auth.role = 'guru_bk' || parent = @request.auth.id",
    deleteRule: "@request.auth.role = 'guru_bk' || parent = @request.auth.id",
    fields: [
      {
        name: "parent",
        type: "relation",
        collectionId: users.id,
        cascadeDelete: true,
        maxSelect: 1,
        required: true,
      },
      {
        name: "student",
        type: "relation",
        collectionId: students.id,
        cascadeDelete: false,
        maxSelect: 1,
        required: false,
      },
      {
        name: "topic_category",
        type: "select",
        required: true,
        maxSelect: 1,
        values: ["Akademik", "Perilaku", "Sosial", "Minat Bakat"],
      },
      { name: "topic", type: "text", required: true, presentable: true },
      { name: "preferred_date", type: "text", required: false },
      { name: "preferred_time", type: "text", required: false },
      { name: "message", type: "text", required: true },
      {
        name: "status",
        type: "select",
        required: true,
        maxSelect: 1,
        values: ["pending", "approved", "rejected", "done"],
      },
      { name: "response_note", type: "text", required: false },
      { name: "created", type: "autodate", onCreate: true, onUpdate: false },
      { name: "updated", type: "autodate", onCreate: true, onUpdate: true },
    ],
    indexes: [
      "CREATE INDEX `idx_consultation_requests_parent` ON `consultation_requests` (`parent`)",
      "CREATE INDEX `idx_consultation_requests_status` ON `consultation_requests` (`status`)",
    ],
  });
  app.save(consultationRequests);

  // 8. View Collection: `v_cases_by_grade`
  const vCasesByGrade = new Collection({
    type: "view",
    name: "v_cases_by_grade",
    listRule: "@request.auth.role = 'guru_bk' || @request.auth.role = 'kepala_sekolah'",
    viewRule: "@request.auth.role = 'guru_bk' || @request.auth.role = 'kepala_sekolah'",
    viewQuery: `
      SELECT
        s.grade_level AS id,
        s.grade_level AS grade_level,
        COUNT(c.id) AS total_cases,
        SUM(CASE WHEN c.is_completed = 1 THEN 1 ELSE 0 END) AS completed_cases
      FROM students s
      LEFT JOIN cases c ON c.student = s.id
      GROUP BY s.grade_level
    `,
  });
  app.save(vCasesByGrade);

  // 9. View Collection: `v_top_students_cases`
  const vTopStudents = new Collection({
    type: "view",
    name: "v_top_students_cases",
    listRule: "@request.auth.role = 'guru_bk' || @request.auth.role = 'kepala_sekolah'",
    viewRule: "@request.auth.role = 'guru_bk' || @request.auth.role = 'kepala_sekolah'",
    viewQuery: `
      SELECT
        s.id AS id,
        s.name AS student_name,
        s.class_name AS student_class,
        s.nisn AS student_nisn,
        COUNT(c.id) AS case_count,
        COALESCE(SUM(c.points), 0) AS total_points
      FROM students s
      INNER JOIN cases c ON c.student = s.id
      GROUP BY s.id
    `,
  });
  app.save(vTopStudents);
}, (app) => {
  const names = [
    "v_top_students_cases",
    "v_cases_by_grade",
    "consultation_requests",
    "parent_consultations",
    "counseling_sessions",
    "cases",
    "case_categories",
    "students",
  ];
  for (const name of names) {
    try {
      const col = app.findCollectionByNameOrId(name);
      app.delete(col);
    } catch (_) {}
  }
});
