/// <reference path="../pb_data/types.d.ts" />

// Perketat updateRule `users`: pengguna hanya boleh mengubah profil/password
// miliknya sendiri, TIDAK boleh mengubah `role` atau `is_active` sendiri.
// Ubah kata sandi sendiri via `oldPassword` (wajib oleh PocketBase untuk
// non-superuser kecuali memiliki manageRule). Guru BK bisa mereset password
// akun orang tua melalui manageRule (tanpa oldPassword).
migrate((app) => {
  const users = app.findCollectionByNameOrId("users");
  users.updateRule =
    "(id = @request.auth.id && @request.body.role:isset = false && @request.body.is_active:isset = false) || @request.auth.role = 'guru_bk'";
  app.save(users);
}, (app) => {
  const users = app.findCollectionByNameOrId("users");
  users.updateRule = "id = @request.auth.id || @request.auth.role = 'guru_bk'";
  app.save(users);
});
