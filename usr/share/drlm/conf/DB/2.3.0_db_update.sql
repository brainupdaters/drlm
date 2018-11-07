-- DRLM v2.3.0 new columns in backups table

PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;

ALTER TABLE backups ADD COLUMN "duration" VARCHAR(12);
ALTER TABLE backups ADD COLUMN "size" VARCHAR(12);

COMMIT;