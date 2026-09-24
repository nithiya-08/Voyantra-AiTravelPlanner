-- Voyantra database migration #6
-- Run once against travel_planner_db after db_migration_5.sql: ties the
-- AI itinerary generator to real approved vendor listings.

USE travel_planner_db;

ALTER TABLE itineraries
  ADD COLUMN suggested_hotel_vendor_id INT NULL,
  ADD COLUMN suggested_food_vendor_id INT NULL,
  ADD CONSTRAINT fk_itin_hotel_vendor FOREIGN KEY (suggested_hotel_vendor_id) REFERENCES vendors(vendor_id) ON DELETE SET NULL,
  ADD CONSTRAINT fk_itin_food_vendor FOREIGN KEY (suggested_food_vendor_id) REFERENCES vendors(vendor_id) ON DELETE SET NULL;
