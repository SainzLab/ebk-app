/// <reference path="../pb_data/types.d.ts" />

// Cegah kebocoran/penyalahgunaan data antar wali murid:
// - Orang tua hanya boleh membuat pengajuan konsultasi atas namanya sendiri
//   dan hanya untuk siswa yang `guardian`-nya adalah dirinya.
// - Orang tua tidak boleh mengubah `parent`/`student`/`status` pengajuan.
// - Wali hanya boleh melihat siswa/kasus yang tertaut (sudah di rule awal).
migrate((app) => {
  const reqs = app.findCollectionByNameOrId("consultation_requests");
  reqs.createRule =
    "@request.auth.role = 'guru_bk' || (@request.auth.role = 'orang_tua' && @request.body.parent = @request.auth.id && @request.body.status = 'pending' && (@request.body.student = '' || @request.body.student.guardian = @request.auth.id))";
  reqs.updateRule =
    "@request.auth.role = 'guru_bk' || (parent = @request.auth.id && @request.body.parent:isset = false && @request.body.student:isset = false && @request.body.status:isset = false && @request.body.response_note:isset = false)";
  app.save(reqs);
}, (app) => {
  const reqs = app.findCollectionByNameOrId("consultation_requests");
  reqs.createRule = "@request.auth.id != ''";
  reqs.updateRule = "@request.auth.role = 'guru_bk' || parent = @request.auth.id";
  app.save(reqs);
});
