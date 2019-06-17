-- DRLM v2.1.0 new Jobs table

PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS "jobs" (
  "idjob" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  "clients_id" int NOT NULL,
  "start_date" datetime NOT NULL,
  "end_date" datetime DEFAULT NULL,
  "last_date" datetime DEFAULT NULL,
  "next_date" datetime NOT NULL,
  "repeat" varchar(15) DEFAULT NULL,
  "enabled" tinyint(1) NOT NULL,
  CONSTRAINT "fk_jobs_clients" FOREIGN KEY ("clients_id") REFERENCES "clients" ("idclient") ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE INDEX IF NOT EXISTS "jobs_fk_jobs_clients" ON "jobs" ("clients_id");
CREATE INDEX IF NOT EXISTS "jobs_next_date" ON "jobs" ("next_date");
CREATE INDEX IF NOT EXISTS "jobs_idjob_UNIQUE" ON "jobs" ("idjob");

COMMIT;