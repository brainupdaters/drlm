-- DRLM v2.4.2 new columns in backups and snaps table
ALTER TABLE backups ADD COLUMN "hold" tinyint(1);
UPDATE backups SET hold=0 WHERE hold is null;

ALTER TABLE snaps ADD COLUMN "hold" tinyint(1);
UPDATE snaps SET hold=0 WHERE hold is null;
