-- Voyantra database migration
-- Run this once against your existing travel_planner_db database
-- (MySQL Workbench, or: mysql -u root -p travel_planner_db < db_migration.sql)
-- before using the new features: share links, expense tracker, admin
-- dashboard, and collaborative trip planning.

USE travel_planner_db;

-- Feature: share trip via public link
ALTER TABLE trips
  ADD COLUMN share_token VARCHAR(64) NULL UNIQUE;

-- Feature: expense tracker
CREATE TABLE IF NOT EXISTS expenses (
  expense_id  INT AUTO_INCREMENT PRIMARY KEY,
  trip_id     INT NOT NULL,
  category    VARCHAR(50) NOT NULL,
  description VARCHAR(255) NOT NULL,
  amount      DECIMAL(10,2) NOT NULL,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (trip_id) REFERENCES trips(trip_id) ON DELETE CASCADE
);

-- Feature: admin dashboard
ALTER TABLE users
  ADD COLUMN is_admin TINYINT(1) NOT NULL DEFAULT 0;

-- After running this, promote your own account to admin with:
-- UPDATE users SET is_admin = 1 WHERE email = 'your-email@example.com';

-- Feature: collaborative trip planning
CREATE TABLE IF NOT EXISTS trip_collaborators (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  trip_id    INT NOT NULL,
  user_id    INT NOT NULL,
  added_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (trip_id) REFERENCES trips(trip_id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  UNIQUE KEY unique_trip_user (trip_id, user_id)
);
