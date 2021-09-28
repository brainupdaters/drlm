-- DRLM v2.4.0 new columns in backups and jobs table

PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;

-- Update table networks
ALTER TABLE networks ADD COLUMN "active" tinyint(1);
UPDATE networks SET active=1 WHERE active is null;

ALTER TABLE networks ADD COLUMN "interface" varchar(45);

-- Update table backups
ALTER TABLE backups ADD COLUMN "config" varchar(45);
UPDATE backups SET config='default' WHERE config is null;

ALTER TABLE backups ADD COLUMN "PXE" tinyint(1);
UPDATE backups SET PXE=1 WHERE active=1;
UPDATE backups SET PXE=0 WHERE active=0;

ALTER TABLE backups ADD COLUMN "type" varchar(20);
UPDATE backups SET type='PXE' where type is null;

ALTER TABLE backups ADD COLUMN "protocol" varchar(20);
UPDATE backups SET protocol='NETFS' where protocol is null;

ALTER TABLE backups ADD COLUMN "date" varchar(16);

-- Update table jobs
ALTER TABLE jobs ADD COLUMN "config" varchar(45);

-- Create new table snaps
CREATE TABLE IF NOT EXISTS "snaps" (
  "idbackup" varchar(14) NOT NULL,
  "idsnap" varchar(14) NOT NULL,
  "date" varchar(16) NOT NULL,
  "active" tinyint(1) NOT NULL,
  "duration" varchar(12) DEFAULT NULL,
  "size" varchar(12) DEFAULT NULL,
  PRIMARY KEY ("idsnap")
  CONSTRAINT "fk_backups_clients" FOREIGN KEY ("idbackup") REFERENCES "backups" ("idbackup") ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Create new table users
CREATE TABLE IF NOT EXISTS "users" (
  "user_name" TEXT NOT NULL UNIQUE PRIMARY KEY,
  "user_password" TEXT NOT NULL
);

INSERT INTO users (user_name, user_password)
VALUES ("admindrlm", "895a8bd10611c7a9297437c8aeebe0bf");

COMMIT;
