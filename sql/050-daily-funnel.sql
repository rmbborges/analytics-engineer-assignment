-- First step: Create the daily funnel table if it not exists
CREATE TABLE IF NOT EXISTS daily_funnel(
    "date" DATE,
    "visitors" INTEGER,
    "viewers" INTEGER,
    "leaders" INTEGER,
    "purchasers" INTEGER,
    "visitor_to_viewer" REAL,
    "viewer_to_leader" REAL,
    "leader_to_purchaser" REAL
);

-- Second step: Create a temporary table to store the latest daily_funnel data
CREATE TEMP TABLE _daily_funnel_control(
    "last_daily_funnel" DATE
);

-- Third step: Query the current daily funnel table and retrieve the last date from it
INSERT INTO _daily_funnel_control
    SELECT 
        COALESCE(
            MAX(date),
            DATE("1970-01-01")
        ) AS last_daily_funnel
    FROM 
        daily_funnel
;

-- Fourth step: Calculate the daily funnel table from daily_stats
INSERT INTO daily_funnel 
    SELECT
        "date",
        visitors,
        viewers,
        leaders,
        purchasers,
        ROUND(CAST(viewers AS REAL) / visitors, 2) AS visitor_to_viewer,
        ROUND(CAST(leaders AS REAL) / viewers, 2) AS viewer_to_leader,
        ROUND(CAST(purchasers AS REAL) / leaders, 2) AS leader_to_purchaser
    FROM
        daily_stats
    WHERE   
        daily_stats.date > (SELECT last_daily_funnel FROM _daily_funnel_control)
;