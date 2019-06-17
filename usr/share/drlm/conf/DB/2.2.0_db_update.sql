-- DRLM v2.2.0 new Counters table

PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS "counters" (
    "idcounter" varchar(20) NOT NULL,
    "value" int(11) NOT NULL,
    PRIMARY KEY ("idcounter")
);

COMMIT;