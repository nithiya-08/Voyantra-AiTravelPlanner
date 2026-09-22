-- Voyantra database migration #4
-- Run once against travel_planner_db after db_migration_3.sql: wishlist,
-- vendor reports, and account blocking for admin user management.

USE travel_planner_db;

ALTER TABLE users
  ADD COLUMN is_blocked TINYINT(1) NOT NULL DEFAULT 0;

CREATE TABLE IF NOT EXISTS vendor_favorites (
  favorite_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id     INT NOT NULL,
  vendor_id   INT NOT NULL,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id) ON DELETE CASCADE,
  UNIQUE KEY unique_user_vendor (user_id, vendor_id)
);

CREATE TABLE IF NOT EXISTS vendor_reports (
  report_id  INT AUTO_INCREMENT PRIMARY KEY,
  vendor_id  INT NOT NULL,
  user_id    INT NOT NULL,
  reason     VARCHAR(500) NOT NULL,
  status     VARCHAR(20) NOT NULL DEFAULT 'OPEN',  -- OPEN, RESOLVED
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
