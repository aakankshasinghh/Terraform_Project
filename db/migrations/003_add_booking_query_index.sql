-- Supports the assessment query's equality predicate on city and range predicate on created_at.
CREATE INDEX idx_hotel_bookings_city_created_at
    ON hotel_bookings (city, created_at);
