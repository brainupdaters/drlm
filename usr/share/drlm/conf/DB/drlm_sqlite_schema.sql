PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS "clients" (
  "idclient" int(11) NOT NULL,
  "cliname" varchar(45) NOT NULL,
  "mac" varchar(17) NOT NULL,
  "ip" varchar(15) NOT NULL,
  "networks_netname" varchar(45) NOT NULL,
  PRIMARY KEY ("cliname")
  CONSTRAINT "fk_clients_networks" FOREIGN KEY ("networks_netname") REFERENCES "networks" ("netname") ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS "networks" (
  "idnetwork" int(11) NOT NULL,
  "netip" varchar(15) NOT NULL,
  "mask" varchar(15) NOT NULL,
  "gw" varchar(15) NOT NULL,
  "domain" varchar(45) DEFAULT NULL,
  "dns" varchar(15) DEFAULT NULL,
  "broadcast" varchar(15) NOT NULL,
  "serverip" varchar(15) NOT NULL,
  "netname" varchar(45) NOT NULL,
  PRIMARY KEY ("netname")
);

CREATE TABLE IF NOT EXISTS "backups" (
  "idbackup" varchar(14) NOT NULL,
  "clients_id" int(11) NOT NULL,
  "drfile" varchar(75) NOT NULL,
  "active" tinyint(1) NOT NULL,
  PRIMARY KEY ("idbackup")
  CONSTRAINT "fk_backups_clients" FOREIGN KEY ("clients_id") REFERENCES "clients" ("idclient") ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE INDEX IF NOT EXISTS "clients_idclients_UNIQUE" ON "clients" ("idclient");
CREATE INDEX IF NOT EXISTS "clients_cliname_UNIQUE" ON "clients" ("cliname");
CREATE INDEX IF NOT EXISTS "clients_fk_clients_networks" ON "clients" ("networks_netname");
CREATE INDEX IF NOT EXISTS "networks_netname_UNIQUE" ON "networks" ("netname");
CREATE INDEX IF NOT EXISTS "networks_idnetworks_UNIQUE" ON "networks" ("idnetwork");
CREATE INDEX IF NOT EXISTS "backups_fk_backups_clients" ON "backups" ("clients_id");

-- 2.1.0 new

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

-- 2.2.0 new

CREATE TABLE IF NOT EXISTS "counters" (
    "idcounter" varchar(20) NOT NULL,
    "value" int(11) NOT NULL,
    PRIMARY KEY ("idcounter")
);

-- 2.3.0 new

ALTER TABLE backups ADD COLUMN "duration" varchar(12);
ALTER TABLE backups ADD COLUMN "size" varchar(12);
ALTER TABLE clients ADD COLUMN "os" varchar(45);
ALTER TABLE clients ADD COLUMN "rear" varchar(45);

-- 2.4.0 new
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

ALTER TABLE backups ADD COLUMN "encrypted" tinyint(1);
UPDATE backups SET encrypted='0' where encrypted is null;

ALTER TABLE backups ADD COLUMN "encryp_pass" varchar(255);

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

-- 2.4.2 new 
-- New columns in backups and snaps table
ALTER TABLE backups ADD COLUMN "hold" tinyint(1);
UPDATE backups SET hold=0 WHERE hold is null;

ALTER TABLE snaps ADD COLUMN "hold" tinyint(1);
UPDATE snaps SET hold=0 WHERE hold is null;

-- DRLM v2.4.5 new 
-- New column in jobs table
ALTER TABLE jobs ADD COLUMN "status" tinyint(1);
UPDATE jobs SET status=0 WHERE status is null;

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

-- New column archived for feature rclone (backups)
ALTER TABLE backups ADD COLUMN "archived" tinyint(1);
UPDATE backups SET archived=0 WHERE archived is null;
