-- DRLM v2.4.12 new
-- Create new table vipclients
CREATE TABLE IF NOT EXISTS vipclients (
  "idvipclient" int(11) NOT NULL,
  "idclient" int(11)
);

-- Create policy table
CREATE TABLE IF NOT EXISTS policy (
  "idclient" int(11) NOT NULL,
  "config" varchar(45) NOT NULL,
  "idbackup" varchar(14) NOT NULL,
  "idsnap" varchar(14),
  "date" varchar(16) NOT NULL,
  "saved_by" TEXT 
);

-- New column scan for feature ClamAV (backups)
ALTER TABLE backups ADD COLUMN "scan" tinyint(1);
UPDATE backups SET scan=0 WHERE scan is null;

-- New column scan for feature Rclone (backups)
ALTER TABLE backups ADD COLUMN "archived" tinyint(1);
UPDATE backups SET archived=0 WHERE scan is null;
