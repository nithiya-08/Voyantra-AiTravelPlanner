-- Voyantra database migration #7
-- Run once against travel_planner_db after db_migration_6.sql: veg/non-veg
-- aware restaurant recommendations with real distance and signature dishes.

USE travel_planner_db;

ALTER TABLE vendors
  ADD COLUMN diet_type VARCHAR(20) NULL,       -- VEG, NON_VEG, BOTH (restaurants only, optional)
  ADD COLUMN signature_dish VARCHAR(150) NULL, -- e.g. "Mysore Pak", "Chettinad Chicken"
  ADD COLUMN latitude DOUBLE NULL,
  ADD COLUMN longitude DOUBLE NULL;

ALTER TABLE trips
  ADD COLUMN food_preference VARCHAR(20) NULL; -- VEG, NON_VEG, or NULL (no preference)
