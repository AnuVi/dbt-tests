{{ config(severity='warn', store_failures=true) }}

-- Kampaanianime kattuvus marketing <-> analytics (mõlemad suunad).
-- direction: missing_in_analytics | missing_in_marketing

WITH marketing AS (

    SELECT DISTINCT
        campaign_name
    FROM {{ ref('stg_marketing') }}
    WHERE campaign_name IS NOT NULL

),

analytics AS (

    SELECT DISTINCT
        campaign_name
    FROM {{ ref('stg_analytics') }}
    WHERE campaign_name IS NOT NULL

),

missing_in_analytics AS (

    SELECT
        m.campaign_name,
        'missing_in_analytics' AS direction
    FROM marketing m
    LEFT JOIN analytics a
        ON m.campaign_name = a.campaign_name
    WHERE a.campaign_name IS NULL

),

missing_in_marketing AS (

    SELECT
        a.campaign_name,
        'missing_in_marketing' AS direction
    FROM analytics a
    LEFT JOIN marketing m
        ON a.campaign_name = m.campaign_name
    WHERE m.campaign_name IS NULL

)

SELECT * FROM missing_in_analytics
UNION ALL
SELECT * FROM missing_in_marketing
