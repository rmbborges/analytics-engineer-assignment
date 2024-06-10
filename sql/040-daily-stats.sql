-- First step:Ccreate the daily stats table if it not exists
CREATE TABLE IF NOT EXISTS daily_stats(
    "date" DATE,
    "visitors" INTEGER,
    "sessions" INTEGER,
    "viewers" INTEGER,
    "view" INTEGER,
    "leaders" INTEGER,
    "leads" INTEGER,
    "purchasers" INTEGER,
    "purchases" INTEGER
);

-- Second step: Create a temporary table to store the latest daily_stats data
CREATE TEMP TABLE _daily_stats_control(
    "last_daily_stats" DATE
);

-- Third step: Query the daily stats table and retrieve the last date from it
INSERT INTO _daily_stats_control
    SELECT 
        COALESCE(
            MAX(date),
            DATE("1970-01-01")
        ) AS last_daily_stats 
    FROM 
        daily_stats
;

-- Fourth step: Insert into daily_stats the requsted data
INSERT INTO daily_stats
    SELECT
        DATE(event_time) AS "date",
        COUNT(DISTINCT user_id) AS visitors,
        COUNT(DISTINCT user_session) AS "sessions",

        COUNT(
            DISTINCT 
                CASE
                    WHEN event_type = 'view' THEN user_id
                    ELSE NULL
                END  
        ) AS viewers,

        COUNT( 
            CASE
                WHEN event_type = 'view' THEN event_time
                ELSE NULL
            END  
        ) AS views,

        COUNT(
            DISTINCT 
                CASE
                    WHEN event_type = 'cart' THEN user_id
                    ELSE NULL
                END  
        ) AS viewers,

        COUNT( 
            CASE
                WHEN event_type = 'cart' THEN event_time
                ELSE NULL
            END  
        ) AS views,

        COUNT(
            DISTINCT 
                CASE
                    WHEN event_type = 'purchase' THEN user_id
                    ELSE NULL
                END  
        ) AS purchasers,
        
        COUNT( 
            CASE
                WHEN event_type = 'purchase' THEN event_time
                ELSE NULL
            END  
        ) AS purchases
    FROM
        event_clean
    WHERE
        DATE(event_clean.event_time) > (SELECT last_daily_stats FROM _daily_stats_control)
    GROUP BY 
        "date"
;

