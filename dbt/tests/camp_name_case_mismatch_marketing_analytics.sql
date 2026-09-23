{{ config(severity='warn', store_failures=true) }}

-- Legacy 03_qa_marketing.sql punkt 1: sama kampaania nimi erineva suurtähega
-- marketing + analytics ühendatud. 0 rida = PASS.

WITH combined AS (

    SELECT campaign_name
    FROM {{ ref('stg_marketing') }}

    UNION ALL

    SELECT campaign_name
    FROM {{ ref('stg_analytics') }}

),

filtered AS (

    SELECT
        TRIM(LOWER(campaign_name)) AS normalized_name,
        campaign_name
    FROM combined
    WHERE campaign_name IS NOT NULL
      AND campaign_name NOT IN ('(not set)', '', '(none)', 'direct')

)

SELECT
    normalized_name,
    COUNT(DISTINCT campaign_name) AS case_variants_found,
    ARRAY_AGG(DISTINCT campaign_name ORDER BY campaign_name) AS variants
FROM filtered
GROUP BY normalized_name
HAVING COUNT(DISTINCT campaign_name) > 1
