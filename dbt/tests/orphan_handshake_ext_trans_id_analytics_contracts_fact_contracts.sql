-- Orphan-handshake test peab kontrollima: iga täidetud external_transaction_id (purchase),
-- mis peaks läbima stg_analytics → stg_contracts → fact_contracts keti, on tõesti kõigis
-- neis etappides olemas — ja raporteerima read, kus see ahel on katkenud.

{{ config(
    severity='warn',
    store_failures=true,
    alias='orphan_hs_ext_trans_id_analytics_contracts_fc'
) }}

WITH analytics_txns AS (

    SELECT DISTINCT external_transaction_id
    FROM {{ ref('stg_analytics') }}
    WHERE event_name = 'purchase'
      AND external_transaction_id IS NOT NULL
      AND external_transaction_id NOT IN ('(not set)', '(none)')

),

contracts_txns AS (

    SELECT DISTINCT external_transaction_id
    FROM {{ ref('stg_contracts') }}
    WHERE external_transaction_id IS NOT NULL

),

fact_txns AS (

    SELECT DISTINCT external_transaction_id
    FROM {{ ref('fact_contracts') }}
    WHERE external_transaction_id IS NOT NULL

),

combined AS (

    SELECT
        COALESCE(a.external_transaction_id, c.external_transaction_id, f.external_transaction_id)
            AS external_transaction_id,
        a.external_transaction_id IS NOT NULL AS in_analytics,
        c.external_transaction_id IS NOT NULL AS in_contracts,
        f.external_transaction_id IS NOT NULL AS in_fact
    FROM analytics_txns a
    FULL OUTER JOIN contracts_txns c USING (external_transaction_id)
    FULL OUTER JOIN fact_txns f USING (external_transaction_id)

)

SELECT
    external_transaction_id,

    CASE
        WHEN in_analytics AND NOT in_contracts
            THEN 'In Analytics -> Missing in Contracts'

        WHEN in_contracts AND NOT in_analytics
            THEN 'In Contracts -> Missing in Analytics'

        WHEN in_contracts AND NOT in_fact
            THEN 'In Contracts -> Missing in fact_contracts'

        ELSE 'Other handshake gap'
    END AS gap_status

FROM combined

WHERE external_transaction_id IS NOT NULL
  AND NOT (in_analytics AND in_contracts AND in_fact)
