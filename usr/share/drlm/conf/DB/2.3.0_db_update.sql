-- DRLM v2.3.0 new columns in backups table

PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;

ALTER TABLE backups ADD COLUMN "duration" varchar(12);
ALTER TABLE backups ADD COLUMN "size" varchar(12);
ALTER TABLE clients ADD COLUMN "os" varchar(45);
ALTER TABLE clients ADD COLUMN "rear" varchar(45);

COMMIT;