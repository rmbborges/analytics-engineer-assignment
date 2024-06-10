-- First step: create the event_raw table following the file schema
CREATE TABLE IF NOT EXISTS event_raw(
    "event_time" TEXT,
    "event_type" TEXT,
    "product_id" TEXT,
    "category_id" TEXT,
    "category_code" TEXT,
    "brand" TEXT,
    "price" TEXT,
    "user_id" TEXT,
    "user_session" TEXT
);

