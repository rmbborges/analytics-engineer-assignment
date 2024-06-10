-- First step: Create the daily sales table if it not exists
CREATE TABLE IF NOT EXISTS daily_sales(
    "date" DATE,
    "total_sales" REAL
);

-- Second step: Create a temporary table to store the latest daily_sales data
CREATE TEMP TABLE _daily_sale_control(
    "last_daily_sale" DATE
);

-- Third step: Query the daily sales table and retrieve the last date from it
INSERT INTO _daily_sale_control
    SELECT 
        COALESCE(
            MAX(date),
            DATE("1970-01-01")
        ) AS last_daily_sale 
    FROM 
        daily_sales
;

-- Fourth step: Insert into daily_sales the aggregated daily total_sales data 
INSERT INTO daily_sales
    SELECT
        DATE(event_time) AS "date",
        ROUND(SUM(price), 2) AS total_sales
    FROM
        event_clean
    WHERE
        event_type = 'purchase'
        AND DATE(event_clean.event_time) > (SELECT last_daily_sale FROM _daily_sale_control)
    GROUP BY 
        "date"
;