-- First step: Create a temporary table to store data loaded from all files
CREATE TEMP TABLE _tmp_event_raw(
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

-- Second step: Create a temporary table to store the last event of event_raw
CREATE TEMP TABLE _last_event_raw_control(
    "last_event_time" DATETIME
);

-- Third step: Insert into the control temporary table the last event from event_raw
INSERT INTO _last_event_raw_control
    SELECT 
        COALESCE(
            MAX(DATETIME(SUBSTR(event_time, 1, 19))),
            DATETIME("1970-01-01 00:00:00")
        ) AS last_event_time 
    FROM 
        event_raw
;

-- Fourth step: Get all files and insert the data into event_raw temporary table
.mode csv
.import '| tail -n +2 -q data/*.csv'  _tmp_event_raw

-- Fifth step: Importing the new data from temporary table into the event_raw table based on the last event_time control
INSERT INTO event_raw 
    SELECT
        event_time,
        event_type,
        product_id,
        category_id,
        category_code,
        brand,
        price,
        user_id,
        user_session
    FROM
        _tmp_event_raw
    WHERE
        DATETIME(SUBSTR(event_time, 1, 19)) > (SELECT last_event_time FROM _last_event_raw_control)