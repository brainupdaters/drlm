PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS "clients" (
  "idclient" int(11) NOT NULL ,
  "cliname" varchar(45) NOT NULL,
  "mac" varchar(17) NOT NULL,
  "ip" varchar(15) NOT NULL,
  "networks_netname" varchar(45) NOT NULL,
  PRIMARY KEY ("cliname")
  CONSTRAINT "fk_clients_networks" FOREIGN KEY ("networks_netname") REFERENCES "networks" ("netname") ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE TABLE IF NOT EXISTS "networks" (
  "idnetwork" int(11) NOT NULL ,
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
)

COMMIT;
