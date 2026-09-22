-- Voyantra database migration #3
-- Run once against travel_planner_db before using: local vendor marketplace
-- (vendor signup, admin approval, tourist discovery, reviews & inquiries).

USE travel_planner_db;

ALTER TABLE users
  ADD COLUMN is_vendor TINYINT(1) NOT NULL DEFAULT 0;

CREATE TABLE IF NOT EXISTS vendors (
  vendor_id        INT AUTO_INCREMENT PRIMARY KEY,
  user_id          INT NOT NULL,
  business_name    VARCHAR(150) NOT NULL,
  category         VARCHAR(30) NOT NULL,      -- HOTEL, HOMESTAY, GUIDE, TRANSPORT, ACTIVITY, RESTAURANT
  description      TEXT NULL,
  city             VARCHAR(100) NOT NULL,
  state            VARCHAR(100) NULL,
  address          VARCHAR(255) NULL,
  phone            VARCHAR(15) NOT NULL,
  email            VARCHAR(150) NULL,
  price_range      VARCHAR(50) NULL,
  photo_url        VARCHAR(500) NULL,
  status           VARCHAR(20) NOT NULL DEFAULT 'PENDING',  -- PENDING, APPROVED, REJECTED
  rejection_reason VARCHAR(255) NULL,
  created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS vendor_inquiries (
  inquiry_id    INT AUTO_INCREMENT PRIMARY KEY,
  vendor_id     INT NOT NULL,
  user_id       INT NOT NULL,
  message       VARCHAR(500) NOT NULL,
  contact_phone VARCHAR(15) NULL,
  travel_dates  VARCHAR(100) NULL,
  status        VARCHAR(20) NOT NULL DEFAULT 'NEW',  -- NEW, RESPONDED (reserved for future use)
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS vendor_reviews (
  review_id  INT AUTO_INCREMENT PRIMARY KEY,
  vendor_id  INT NOT NULL,
  user_id    INT NOT NULL,
  rating     TINYINT NOT NULL,
  comment    VARCHAR(500) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  UNIQUE KEY unique_vendor_user (vendor_id, user_id)
);
