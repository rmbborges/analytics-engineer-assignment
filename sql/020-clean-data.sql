-- First step: Create the event_clean table following the provided schema
CREATE TABLE IF NOT EXISTS event_clean(
    "event_time" DATETIME,
    "event_type" TEXT,
    "product_id" INTEGER,
    "category_id" INTEGER,
    "category_code" TEXT,
    "brand" TEXT,
    "price" REAL,
    "user_id" INTEGER,
    "user_session" TEXT
);

-- Second step: Check the table to store the latest event_time
CREATE TEMP TABLE _last_event_clean_control(
    "last_event_time" DATETIME
);

-- Third step: Query the clean table and retrieve the last event_time from it
INSERT INTO _last_event_clean_control
    SELECT 
        COALESCE(
            MAX(event_time),
            DATETIME("1970-01-01 00:00:00")
        ) AS last_event_time 
    FROM 
        event_clean
;

-- Fourth step: Clean and import the data into event_clean
INSERT INTO event_clean
    SELECT
        DATETIME(SUBSTR(event_time, 1, 19)) AS event_time,

        CASE
            WHEN NULLIF(event_type, "") IS NULL THEN "None"
            ELSE TRIM(event_type)
        END AS event_type,

        CASE
            WHEN NULLIF(product_id, "") IS NULL THEN 0
            ELSE CAST(product_id AS INTEGER)
        END AS product_id, 

        CASE
            WHEN NULLIF(category_id, "") IS NULL THEN 0
            ELSE CAST(category_id AS INTEGER)
        END AS category_id, 

        CASE
            WHEN NULLIF(category_code, "") IS NULL THEN "None"
            ELSE TRIM(category_code)
        END AS category_code,

        CASE
            WHEN NULLIF(brand, "") IS NULL THEN "None"
            ELSE TRIM(brand)
        END AS brand,

        CAST(price AS REAL) AS price,
        CAST(user_id AS INTEGER) AS user_id, 
        
        CASE
            WHEN NULLIF(user_session, "") IS NULL THEN "None"
            ELSE user_session
        END AS user_session
    FROM
        event_raw
    WHERE
        DATETIME(SUBSTR(event_time, 1, 19)) > (SELECT last_event_time FROM _last_event_clean_control)
        AND NULLIF(event_time, '') IS NOT NULL
        AND CAST(price AS REAL) >= 0
        AND TRIM(category_id) GLOB '*[0-9]*'
        AND TRIM(product_id) GLOB '*[0-9]*'
        AND TRIM(user_id) GLOB '*[0-9]*'
        AND NULLIF(user_id, '') IS NOT NULL
;
