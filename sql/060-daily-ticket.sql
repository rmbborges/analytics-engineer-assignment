-- First step: Create the daily ticket table if it not exists
CREATE TABLE IF NOT EXISTS daily_ticket(
    "date" DATE,
    "total_sales" REAL,
    "min_ticket" REAL,
    "25th_perc_ticket" REAL,
    "50th_perc_ticket" REAL,
    "75th_perc_ticket" REAL,
    "max_ticket" REAL
);

-- Second step: Check the table to store the latest daily_ticket
CREATE TEMP TABLE _daily_ticket_control(
    "last_daily_ticket" DATE
);

-- Third step: Query the daily ticket table and retrieve the last date from it
INSERT INTO _daily_ticket_control
    SELECT 
        COALESCE(
            MAX(date),
            DATE("1970-01-01")
        ) AS last_daily_ticket
    FROM 
        daily_ticket
;

-- Fourth step: Calculate the daily ticket percentiles
INSERT INTO daily_ticket
    WITH
    purchase_events AS (
        SELECT
            DATE(event_time) AS "date",
            user_session,
            ROUND(SUM(price), 2) AS user_session_ticket_value
        FROM
            event_clean
        WHERE
            DATE(event_time) > (SELECT last_daily_ticket FROM _daily_ticket_control)
            AND event_type = 'purchase'
        GROUP BY 
            "date",
            user_session
    ),
    daily_purchases_ordered AS (
        SELECT
            "date",
            user_session_ticket_value,

            SUM(user_session_ticket_value) OVER(
                PARTITION BY "date" 
            ) AS daily_total_sales_value,

            MIN(user_session_ticket_value) OVER(
                PARTITION BY "date"
            ) AS min_daily_ticket_value,

            MAX(user_session_ticket_value) OVER(
                PARTITION BY "date"
            ) AS max_daily_ticket_value,

            COUNT(*) OVER(
                PARTITION BY "date"
            ) AS daily_total_user_session_count,

            ROW_NUMBER() OVER(
                PARTITION BY "date"
                ORDER BY user_session_ticket_value ASC
            ) AS daily_ticket_rn
        FROM
            purchase_events
    ),
    daily_purchases_percentiles AS (
        SELECT
            "date",
            CAST(MAX(daily_total_user_session_count) * 0.25 AS INTEGER) AS "25_perc_rn",
            CAST(MAX(daily_total_user_session_count) * 0.50 AS INTEGER) AS "50_perc_rn",
            CAST(MAX(daily_total_user_session_count) * 0.75 AS INTEGER) AS "75_perc_rn"
        FROM
            daily_purchases_ordered
        GROUP BY 
            "date"
    )

    SELECT
        "date",
        ROUND(MAX(dpo.daily_total_sales_value), 2) AS total_sales,
        MAX(dpo.min_daily_ticket_value) AS min_ticket,

        MAX(
            CASE
                WHEN dpp."25_perc_rn" = dpo.daily_ticket_rn THEN dpo.user_session_ticket_value
                ELSE 0
            END
        ) AS "25th_perc_ticket",

        MAX(
            CASE
                WHEN dpp."50_perc_rn" = dpo.daily_ticket_rn THEN dpo.user_session_ticket_value
                ELSE 0
            END
        ) AS "50th_perc_ticket",

        MAX(
            CASE
                WHEN dpp."75_perc_rn" = dpo.daily_ticket_rn THEN dpo.user_session_ticket_value
                ELSE 0
            END
        ) AS "75th_perc_ticket",

        MAX(dpo.max_daily_ticket_value) AS max_ticket
    FROM
        daily_purchases_ordered AS dpo 
    INNER JOIN 
        daily_purchases_percentiles AS dpp USING("date")
    GROUP BY 
        "date"
;



