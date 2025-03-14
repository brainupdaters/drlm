-- DRLM v2.4.13 new
-- New column scan for feature ClamAV (snaps)
ALTER TABLE snaps ADD COLUMN "scan" tinyint(1);
UPDATE snaps SET scan=0 WHERE scan is null;

-- New column archived for feature rclone (snaps)
ALTER TABLE snaps ADD COLUMN "archived" tinyint(1);
UPDATE snaps SET archived=0 WHERE archived is null;
