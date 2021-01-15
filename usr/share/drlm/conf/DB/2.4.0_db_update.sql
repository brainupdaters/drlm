-- DRLM v2.4.0 new columns in backups and jobs table

PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;

ALTER TABLE backups ADD COLUMN "config" VARCHAR(45);
ALTER TABLE jobs ADD COLUMN "config" VARCHAR(45);

COMMIT;