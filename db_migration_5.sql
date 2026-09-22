-- Voyantra database migration #5
-- Run once against travel_planner_db after db_migration_4.sql: vendor trust
-- signals (website link, admin verification badge).

USE travel_planner_db;

ALTER TABLE vendors
  ADD COLUMN website_url VARCHAR(500) NULL,
  ADD COLUMN is_verified TINYINT(1) NOT NULL DEFAULT 0;
