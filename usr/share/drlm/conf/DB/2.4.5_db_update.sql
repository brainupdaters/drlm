-- DRLM v2.4.5 new columns in jobs table
ALTER TABLE jobs ADD COLUMN "status" tinyint(1);
UPDATE jobs SET status=0 WHERE status is null;
