-- Orphan-handshake test peab kontrollima: iga täidetud external_lead_id, mis peaks läbima
-- stg_analytics → stg_orders → fact_orders keti, on tõesti kõigis neis etappides olemas —
-- ja raporteerima read, kus see ahel on katkenud.

{{ config(severity='warn', store_failures=true) }}

WITH analytics_leads AS (

    SELECT DISTINCT external_lead_id
    FROM {{ ref('stg_analytics') }}
    WHERE event_name = 'generate_lead'
      AND external_lead_id IS NOT NULL
      AND external_lead_id NOT IN ('(not set)', '(none)')

),

orders_leads AS (

    SELECT DISTINCT external_lead_id
    FROM {{ ref('stg_orders') }}
    WHERE external_lead_id IS NOT NULL

),

fact_leads AS (

    SELECT DISTINCT external_lead_id
    FROM {{ ref('fact_orders') }}
    WHERE external_lead_id IS NOT NULL

),

combined AS (

    SELECT
        COALESCE(a.external_lead_id, o.external_lead_id, f.external_lead_id) AS external_lead_id,
        a.external_lead_id IS NOT NULL AS in_analytics,
        o.external_lead_id IS NOT NULL AS in_orders,
        f.external_lead_id IS NOT NULL AS in_fact
    FROM analytics_leads a
    FULL OUTER JOIN orders_leads o USING (external_lead_id)
    FULL OUTER JOIN fact_leads f USING (external_lead_id)

)

SELECT
    external_lead_id,
    CASE
        WHEN in_analytics AND NOT in_orders THEN 'In Analytics -> Missing in Orders'
        WHEN in_orders AND NOT in_analytics THEN 'In Orders -> Missing in Analytics'
        WHEN in_orders AND NOT in_fact THEN 'In Orders -> Missing in fact_orders'
        ELSE 'Other handshake gap'
    END AS gap_status
FROM combined
WHERE external_lead_id IS NOT NULL
  AND NOT (in_analytics AND in_orders AND in_fact)
