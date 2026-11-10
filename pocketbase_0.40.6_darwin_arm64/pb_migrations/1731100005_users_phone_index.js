/// <reference path="../pb_data/types.d.ts" />

// Email dan nomor telepon kini disimpan terpisah (`email` & `phone`).
// Pastikan nomor telepon unik (kosong diabaikan). Jika data lama sudah
// memiliki nomor ganda, index dilewati agar migrasi tidak menggagalkan startup.
migrate((app) => {
  const users = app.findCollectionByNameOrId("users");
  const idx = "CREATE UNIQUE INDEX `idx_users_phone` ON `users` (`phone`) WHERE `phone` != ''";
  if (!users.indexes.includes(idx)) {
    users.indexes.push(idx);
    try {
      app.save(users);
    } catch (e) {
      console.log("[migrate] skip unique phone index:", e);
    }
  }
}, (app) => {
  const users = app.findCollectionByNameOrId("users");
  users.indexes = users.indexes.filter((i) => !i.includes("idx_users_phone"));
  app.save(users);
});
