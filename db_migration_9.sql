-- Voyantra database migration #9
-- Run once against travel_planner_db after db_migration_8.sql: a shared
-- photo gallery per destination, contributed by tourists who've actually
-- been there — separate from the stock/AI photo carousel, and separate
-- from vendor-review photos (which are tied to one specific vendor).

USE travel_planner_db;

CREATE TABLE IF NOT EXISTS destination_photos (
  photo_id    INT AUTO_INCREMENT PRIMARY KEY,
  destination VARCHAR(150) NOT NULL,
  user_id     INT NOT NULL,
  photo_url   VARCHAR(500) NOT NULL,
  caption     VARCHAR(255) NULL,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
