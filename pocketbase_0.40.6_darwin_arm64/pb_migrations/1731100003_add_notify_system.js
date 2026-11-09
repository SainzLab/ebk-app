/// <reference path="../pb_data/types.d.ts" />

migrate((app) => {
  const users = app.findCollectionByNameOrId("users");

  users.fields.add(new BoolField({
    name: "notify_system",
  }));

  app.save(users);
}, (app) => {
  const users = app.findCollectionByNameOrId("users");
  users.fields.removeByName("notify_system");
  app.save(users);
});
