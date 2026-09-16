-- Voyantra database migration #2
-- Run once against travel_planner_db before using: trip countdown, currency
-- converter, local emergency info, trip journal/rating, day favorites, and
-- the pre-trip checklist.

USE travel_planner_db;

-- Feature: trip countdown + basis for currency/checklist (domestic vs international)
ALTER TABLE trips
  ADD COLUMN start_date DATE NULL,
  ADD COLUMN country_code VARCHAR(2) NULL;

-- Feature: favorite/highlight specific days of an itinerary
ALTER TABLE itineraries
  ADD COLUMN is_favorite TINYINT(1) NOT NULL DEFAULT 0;

-- Feature: post-trip journal & rating (one entry per trip)
CREATE TABLE IF NOT EXISTS trip_journal (
  trip_id    INT PRIMARY KEY,
  rating     TINYINT NULL,
  notes      TEXT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (trip_id) REFERENCES trips(trip_id) ON DELETE CASCADE
);

-- Feature: pre-trip checklist (auto-seeded + custom items)
CREATE TABLE IF NOT EXISTS trip_checklist_items (
  item_id    INT AUTO_INCREMENT PRIMARY KEY,
  trip_id    INT NOT NULL,
  item_text  VARCHAR(255) NOT NULL,
  is_checked TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (trip_id) REFERENCES trips(trip_id) ON DELETE CASCADE
);
