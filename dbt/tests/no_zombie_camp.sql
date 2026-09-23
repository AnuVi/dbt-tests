{{ config(severity='warn', store_failures=true) }}

-- Zombie campaigns: analyticsis tasuline liiklus, aga marketingus pole vastavat
-- kulu/kampaaniat (legacy 03_qa_marketing.sql punkt 4). 0 rida = PASS.

SELECT
    a.country,
    a.campaign_name,
    a.utm_source,
    a.utm_medium,
    COUNT(*) AS session_count
FROM {{ ref('stg_analytics') }} AS a
LEFT JOIN {{ ref('stg_marketing') }} AS m
    ON TRIM(LOWER(a.campaign_name)) = TRIM(LOWER(m.campaign_name))
    AND TRIM(UPPER(a.country)) = TRIM(UPPER(m.country))
WHERE m.campaign_name IS NULL
  AND a.campaign_name IS NOT NULL
  AND a.campaign_name NOT IN ('(not set)', '(none)', 'direct', '')
  AND (
      a.utm_medium ~* '^.*cp.*|ppc|retargeting|paid.*$'
      OR LOWER(TRIM(a.utm_medium)) IN (
          'display', 'banner', 'expandable', 'interstitial', 'cpm', 'affiliate'
      )
  )
GROUP BY a.country, a.campaign_name, a.utm_source, a.utm_medium
HAVING COUNT(*) > 0
