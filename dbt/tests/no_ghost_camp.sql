{{ config(severity='warn', store_failures=true) }}

-- Ghost campaigns: marketing kulutab (cost > 0), aga analyticsis pole vastet
-- (legacy 03_qa_marketing.sql punkt 3).

SELECT
    m.campaign_name,
    SUM(m.cost) AS wasted_spend
FROM {{ ref('stg_marketing') }} AS m
LEFT JOIN {{ ref('stg_analytics') }} AS a
    ON TRIM(LOWER(m.campaign_name)) = TRIM(LOWER(a.campaign_name))
    AND TRIM(UPPER(m.country)) = TRIM(UPPER(a.country))
WHERE a.campaign_name IS NULL
GROUP BY m.campaign_name
HAVING SUM(m.cost) > 0
