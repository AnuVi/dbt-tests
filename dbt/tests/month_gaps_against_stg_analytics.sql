-- Kuu-põhine ajaline kattuvus: millistes kuudes on andmeid ühes staging-tabelis,
-- aga partner-tabelis samas kuus 0 rida.

{{ config(severity='warn', store_failures=true) }}

SELECT *
FROM {{ ref('date_coverage_gaps_by_month') }}
