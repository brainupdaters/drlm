-- DRLM v2.4.0 new columns in backups and jobs table

PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;

ALTER TABLE backups ADD COLUMN "config" VARCHAR(45);
UPDATE backups SET config='default' WHERE config='';

ALTER TABLE backups ADD COLUMN "PXE" tinyint(1);
UPDATE backups SET PXE=1 WHERE active=1;
UPDATE backups SET PXE=0 WHERE active=0;

ALTER TABLE backups ADD COLUMN "type" tinyint(1);
UPDATE backups SET type=1 where type='';
-- type 0 = data backup only
-- type 1 = PXE rescue system
-- type 1 = ISO rescue system

ALTER TABLE jobs ADD COLUMN "config" VARCHAR(45);

COMMIT;