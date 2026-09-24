-- Voyantra database migration #8
-- Run once against travel_planner_db after db_migration_7.sql: lets
-- tourists attach a real photo to their vendor review, for other
-- tourists deciding whether to visit.

USE travel_planner_db;

ALTER TABLE vendor_reviews
  ADD COLUMN photo_url VARCHAR(500) NULL;
