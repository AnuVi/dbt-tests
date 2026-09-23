-- Kuu-põhine ajaline kattuvus stg_marketingu vastu:
-- millistes kuudes on andmeid ühes tabelis, aga vastaspooles samas kuus 0 rida.
-- Kaetud tabelid: stg_marketing, stg_analytics, stg_orders, stg_contracts (ilma stg_recordings).

{{ config(severity='warn', store_failures=true) }}

WITH marketing_months AS (
    SELECT
        DATE_TRUNC('month', date_key)::DATE AS month_start,
        COUNT(*) AS row_count
    FROM {{ ref('stg_marketing') }}
    WHERE date_key IS NOT NULL
    GROUP BY 1
),

analytics_months AS (
    SELECT
        DATE_TRUNC('month', date_key)::DATE AS month_start,
        COUNT(*) AS row_count
    FROM {{ ref('stg_analytics') }}
    WHERE date_key IS NOT NULL
    GROUP BY 1
),

orders_months AS (
    SELECT
        DATE_TRUNC('month', date_key)::DATE AS month_start,
        COUNT(*) AS row_count
    FROM {{ ref('stg_orders') }}
    WHERE date_key IS NOT NULL
    GROUP BY 1
),

contracts_months AS (
    SELECT
        DATE_TRUNC('month', date_key)::DATE AS month_start,
        COUNT(*) AS row_count
    FROM {{ ref('stg_contracts') }}
    WHERE date_key IS NOT NULL
    GROUP BY 1
),

gaps AS (

    -- marketing -> analytics
    SELECT
        m.month_start,
        TO_CHAR(m.month_start, 'MM.YYYY') AS month_label,
        'stg_marketing' AS left_table,
        'stg_analytics' AS right_table,
        m.row_count AS left_rows,
        COALESCE(a.row_count, 0) AS right_rows,
        'In Marketing -> Missing in Analytics' AS gap_status
    FROM marketing_months m
    LEFT JOIN analytics_months a ON m.month_start = a.month_start
    WHERE a.month_start IS NULL

    UNION ALL

    -- analytics -> marketing
    SELECT
        a.month_start,
        TO_CHAR(a.month_start, 'MM.YYYY') AS month_label,
        'stg_analytics' AS left_table,
        'stg_marketing' AS right_table,
        a.row_count AS left_rows,
        COALESCE(m.row_count, 0) AS right_rows,
        'In Analytics -> Missing in Marketing' AS gap_status
    FROM analytics_months a
    LEFT JOIN marketing_months m ON a.month_start = m.month_start
    WHERE m.month_start IS NULL

    UNION ALL

    -- marketing -> orders
    SELECT
        m.month_start,
        TO_CHAR(m.month_start, 'MM.YYYY') AS month_label,
        'stg_marketing' AS left_table,
        'stg_orders' AS right_table,
        m.row_count AS left_rows,
        COALESCE(o.row_count, 0) AS right_rows,
        'In Marketing -> Missing in Orders' AS gap_status
    FROM marketing_months m
    LEFT JOIN orders_months o ON m.month_start = o.month_start
    WHERE o.month_start IS NULL

    UNION ALL

    -- orders -> marketing
    SELECT
        o.month_start,
        TO_CHAR(o.month_start, 'MM.YYYY') AS month_label,
        'stg_orders' AS left_table,
        'stg_marketing' AS right_table,
        o.row_count AS left_rows,
        COALESCE(m.row_count, 0) AS right_rows,
        'In Orders -> Missing in Marketing' AS gap_status
    FROM orders_months o
    LEFT JOIN marketing_months m ON o.month_start = m.month_start
    WHERE m.month_start IS NULL

    UNION ALL

    -- marketing -> contracts
    SELECT
        m.month_start,
        TO_CHAR(m.month_start, 'MM.YYYY') AS month_label,
        'stg_marketing' AS left_table,
        'stg_contracts' AS right_table,
        m.row_count AS left_rows,
        COALESCE(c.row_count, 0) AS right_rows,
        'In Marketing -> Missing in Contracts' AS gap_status
    FROM marketing_months m
    LEFT JOIN contracts_months c ON m.month_start = c.month_start
    WHERE c.month_start IS NULL

    UNION ALL

    -- contracts -> marketing
    SELECT
        c.month_start,
        TO_CHAR(c.month_start, 'MM.YYYY') AS month_label,
        'stg_contracts' AS left_table,
        'stg_marketing' AS right_table,
        c.row_count AS left_rows,
        COALESCE(m.row_count, 0) AS right_rows,
        'In Contracts -> Missing in Marketing' AS gap_status
    FROM contracts_months c
    LEFT JOIN marketing_months m ON c.month_start = m.month_start
    WHERE m.month_start IS NULL

)

SELECT *
FROM gaps
ORDER BY month_start, gap_status
