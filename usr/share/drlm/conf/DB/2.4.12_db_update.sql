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