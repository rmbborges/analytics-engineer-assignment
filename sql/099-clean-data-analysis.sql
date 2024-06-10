SELECT
    'event_time' AS column,
    'NULL_or_empty_values' AS assertion,
    'error' AS import_behaviour,
    COUNT(*) AS bad_rows_count
FROM
    event_raw
WHERE
    NULLIF(event_time, '') IS NULL

UNION ALL

SELECT
    'event_time' AS column,
    'outside_file_period' AS assertion,
    'warning' AS import_behaviour,
    COUNT(*) AS bad_rows_count
FROM
    event_raw
WHERE
    DATE(DATETIME(SUBSTR(event_time, 1, 19))) NOT BETWEEN DATE('2020-01-01') AND DATE('2020-01-31')

UNION ALL

SELECT
    'event_type' AS column,
    'NULL_or_empty_values' AS assertion,
    'warning' AS import_behaviour,
    COUNT(*) AS bad_rows_count
FROM
    event_raw
WHERE
    NULLIF(event_type, '') IS NULL


UNION ALL

SELECT
    'event_type' AS column,
    'event_type_outside_expected_values' AS assertion,
    'warning' AS import_behaviour,
    COUNT(*) AS bad_rows_count
FROM
    event_raw
WHERE
    TRIM(event_type) NOT IN ("view", "cart", "remove_from_cart", "purchase")

UNION ALL

SELECT
    'product_id' AS column,
    'NULL_or_empty_values' AS assertion,
    'warning' AS import_behaviour,
    COUNT(*) AS bad_rows_count
FROM
    event_raw
WHERE
    NULLIF(product_id, '') IS NULL

UNION ALL

SELECT
    'product_id' AS column,
    'product_id_non_numeric_values' AS assertion,
    'warning' AS import_behaviour,
    COUNT(*) AS bad_rows_count
FROM
    event_raw
WHERE
    TRIM(product_id) NOT GLOB '*[0-9]*'

UNION ALL

SELECT
    'category_id' AS column,
    'NULL_or_empty_values' AS assertion,
    'warning' AS import_behaviour,
    COUNT(*) AS bad_rows_count
FROM
    event_raw
WHERE
    NULLIF(category_id, '') IS NULL

UNION ALL

SELECT
    'category_id' AS column,
    'category_id_non_numeric_values' AS assertion,
    'warning' AS import_behaviour,
    COUNT(*) AS bad_rows_count
FROM
    event_raw
WHERE
    TRIM(category_id) NOT GLOB '*[0-9]*'

UNION ALL

SELECT
    'category_code' AS column,
    'NULL_or_empty_values' AS assertion,
    'warning' AS import_behaviour,
    COUNT(*) AS bad_rows_count
FROM
    event_raw
WHERE
    NULLIF(category_code, '') IS NULL

UNION ALL

SELECT
    'brand' AS column,
    'NULL_or_empty_values' AS assertion,
    'warning' AS import_behaviour,
    COUNT(*) AS bad_rows_count
FROM
    event_raw
WHERE
    NULLIF(brand, '') IS NULL

UNION ALL

SELECT
    'price' AS column,
    'NULL_or_empty_values' AS assertion,
    'warning' AS import_behaviour,
    COUNT(*) AS bad_rows_count
FROM
    event_raw
WHERE
    NULLIF(price, '') IS NULL

UNION ALL

SELECT
    'price' AS column,
    'price_with_non_numerical_values' AS assertion,
    'warning' AS import_behaviour,
    COUNT(*) AS bad_rows_count
FROM
    event_raw
WHERE
    TRIM(price) NOT GLOB '*[0-9.]*'

UNION ALL

SELECT
    'price' AS column,
    'price_with_negative_values' AS assertion,
    'error' AS import_behaviour,
    COUNT(*) AS bad_rows_count
FROM
    event_raw
WHERE
    CAST(price AS REAL) < 0

UNION ALL

SELECT
    'user_id' AS column,
    'NULL_or_empty_values' AS assertion,
    'error' AS import_behaviour,
    COUNT(*) AS bad_rows_count
FROM
    event_raw
WHERE
    NULLIF(user_id, '') IS NULL

UNION ALL

SELECT
    'user_id' AS column,
    'user_id_with_non_numerical_values' AS assertion,
    'warning' AS import_behaviour,
    COUNT(*) AS bad_rows_count
FROM
    event_raw
WHERE
    TRIM(user_id) NOT GLOB '*[0-9]*'

UNION ALL

SELECT
    'user_session' AS column,
    'NULL_or_empty_values' AS assertion,
    'warning' AS import_behaviour,
    COUNT(*) AS bad_rows_count
FROM
    event_raw
WHERE
    NULLIF(user_session, '') IS NULL

ORDER BY 
    bad_rows_count DESC;