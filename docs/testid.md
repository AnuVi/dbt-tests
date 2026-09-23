# dbt testid

_Uuendatatud 04.06.2026_

**Eeldus:** teenused ja andmetoru töövoog käivitatud — vt [seadistamine.md](seadistamine.md), testid käivituvad automaatselt. 

Projektis jookseb kokku **75** `dbt test`; selles juhendis on **33 andmekvaliteeditesti**.

Testide valik põhineb paljuski pre-dbt ajal legacy QA-s kirjeldatud kontrollidel — vt [scripts/legacy/qa/](../scripts/legacy/qa/) ([scripts/legacy/README.md](../scripts/legacy/README.md)).

## Sisukord

1. [Testide kiirülevaade](#testide-kiirülevaade)
2. [33 testide tulemused — 04.06.2026](#33-testide-tulemused--04062026)
3. [Kuidas lugeda tulemusi?](#kuidas-lugeda-tulemusi)
4. [Testide kirjeldused](#testide-kirjeldused)
   - [Staging](#staging-dbtmodelsstaging)
     - [`negative_cost_stg_marketing`](#negative_cost_stg_marketing)
     - [`not_null_campaign_name_stg_marketing`](#not_null_campaign_name_stg_marketing)
     - [`not_null_external_lead_id_generate_lead_google`](#not_null_external_lead_id_generate_lead_google)
     - [`not_null_external_transaction_id_purchase_google`](#not_null_external_transaction_id_purchase_google)
     - [`invalid_external_lead_id_generate_lead`](#invalid_external_lead_id_generate_lead)
     - [`unique_external_lead_id_generate_lead`](#unique_external_lead_id_generate_lead)
     - [`invalid_external_transaction_id_purchase`](#invalid_external_transaction_id_purchase)
     - [`unique_external_transaction_id_purchase`](#unique_external_transaction_id_purchase)
     - [`unique_external_lead_id_stg_orders`](#unique_external_lead_id_stg_orders)
     - [`recency_stg_marketing_25_days`](#recency_stg_marketing_25_days)
     - [`recency_stg_analytics_25_days`](#recency_stg_analytics_25_days)
     - [`no_future_date` (generic)](#no_future_date-generic)
   - [Marts](#marts-dbtmodelsmarts)
     - [`unique_fact_contracts_system_transaction_id`](#unique_fact_contracts_system_transaction_id)
     - [`unique_fact_orders_system_transaction_id`](#unique_fact_orders_system_transaction_id)
     - [`not_null_fact_orders_system_transaction_id`](#not_null_fact_orders_system_transaction_id)
     - [`B2B_B2C_customer_segment_fact_orders`](#b2b_b2c_customer_segment_fact_orders)
     - [`lead_opportunity_gte_created_dim_lead`](#lead_opportunity_gte_created_dim_lead)
     - [`lead_offer_gte_opportunity_dim_lead`](#lead_offer_gte_opportunity_dim_lead)
     - [`lead_quote_gte_offer_dim_lead`](#lead_quote_gte_offer_dim_lead)
     - [`lead_no_offer_without_opportunity_dim_lead`](#lead_no_offer_without_opportunity_dim_lead)
     - [`lead_no_quote_without_offer_dim_lead`](#lead_no_quote_without_offer_dim_lead)
   - [Singular](#singular-dbttests)
     - [`camp_name_gap_marketing_analytics`](#camp_name_gap_marketing_analytics)
     - [`camp_name_case_mismatch_marketing_analytics`](#camp_name_case_mismatch_marketing_analytics)
     - [Näited](#näited)
     - [Gap vs case (lühidalt)](#gap-vs-case-lühidalt)
     - [`no_ghost_camp`](#no_ghost_camp)
     - [`no_zombie_camp`](#no_zombie_camp)
     - [`orphan_handshake_ext_lead_id_analytics_orders_fact_orders`](#orphan_handshake_ext_lead_id_analytics_orders_fact_orders)
     - [`orphan_handshake_ext_trans_id_analytics_contracts_fact_contracts`](#orphan_handshake_ext_trans_id_analytics_contracts_fact_contracts)
     - [`month_gaps_against_stg_marketing`](#month_gaps_against_stg_marketing)
     - [`month_gaps_against_stg_analytics`](#month_gaps_against_stg_analytics)
5. [Monitooring (`dbt/models/monitoring/`)](#monitooring-dbtmodelsmonitoring)

---

## Testide kiirülevaade

| Asukoht | Mudel | Test | Severity | Tüüp |
|---------|-------|------|----------|------|
| `dbt/models/staging` | | | | |
| | `stg_marketing` | `negative_cost_stg_marketing` | ERROR | generic |
| | `stg_marketing` | `not_null_campaign_name_stg_marketing` | WARN | generic |
| | `stg_analytics` | `not_null_external_lead_id_generate_lead_google` | WARN | generic |
| | `stg_analytics` | `not_null_external_transaction_id_purchase_google` | WARN | generic |
| | `stg_analytics` | `invalid_external_lead_id_generate_lead` | WARN | generic |
| | `stg_analytics` | `unique_external_lead_id_generate_lead` | WARN | generic |
| | `stg_analytics` | `invalid_external_transaction_id_purchase` | WARN | generic |
| | `stg_analytics` | `unique_external_transaction_id_purchase` | WARN | generic |
| | `stg_orders` | `unique_external_lead_id_stg_orders` | WARN | generic |
| | `stg_marketing` | `recency_stg_marketing_25_days` | WARN | generic |
| | `stg_analytics` | `recency_stg_analytics_25_days` | WARN | generic |
| | `stg_analytics` | `no_future_date_stg_analytics_date_key` | ERROR | generic (`no_future_date`) |
| | `stg_marketing` | `no_future_date_stg_marketing_date_key` | ERROR | generic (`no_future_date`) |
| | `stg_orders` | `no_future_date_stg_orders_date_key` | ERROR | generic (`no_future_date`) |
| | `stg_contracts` | `no_future_date_stg_contracts_date_key` | ERROR | generic (`no_future_date`) |
| | `stg_leads` | `no_future_date_stg_leads_date_key` | ERROR | generic (`no_future_date`) |
| `dbt/models/marts` | | | | |
| | `fact_contracts` | `unique_fact_contracts_system_transaction_id` | WARN | generic |
| | `fact_orders` | `unique_fact_orders_system_transaction_id` | WARN | generic |
| | `fact_orders` | `not_null_fact_orders_system_transaction_id` | WARN | generic |
| | `fact_orders` | `B2B_B2C_customer_segment_fact_orders` | WARN | generic |
| | `dim_lead` | `lead_opportunity_gte_created_dim_lead` | WARN | generic (`dbt_expectations`) |
| | `dim_lead` | `lead_offer_gte_opportunity_dim_lead` | WARN | generic (`dbt_expectations`) |
| | `dim_lead` | `lead_quote_gte_offer_dim_lead` | WARN | generic (`dbt_expectations`) |
| | `dim_lead` | `lead_no_offer_without_opportunity_dim_lead` | WARN | generic |
| | `dim_lead` | `lead_no_quote_without_offer_dim_lead` | WARN | generic |
| `dbt/tests` | | | | |
| | `stg_marketing`, `stg_analytics` | `camp_name_gap_marketing_analytics` | WARN | singular |
| | `stg_marketing`, `stg_analytics` | `camp_name_case_mismatch_marketing_analytics` | WARN | singular |
| | `stg_marketing`, `stg_analytics` | `no_ghost_camp` | WARN | singular |
| | `stg_analytics`, `stg_marketing` | `no_zombie_camp` | WARN | singular |
| | `stg_analytics`, `stg_orders`, `fact_orders` | `orphan_handshake_ext_lead_id_analytics_orders_fact_orders` | WARN | singular |
| | `stg_analytics`, `stg_contracts`, `fact_contracts` | `orphan_handshake_ext_trans_id_analytics_contracts_fact_contracts` | WARN | singular |
| | `stg_marketing`, `stg_analytics`, `stg_orders`, `stg_contracts` | `month_gaps_against_stg_marketing` | WARN | singular |
| | `date_coverage_gaps_by_month` | `month_gaps_against_stg_analytics` | WARN | singular |


---

## 33 testide tulemused — 04.06.2026


**Koond:** PASS=26 · WARN=7 · ERROR=0 · TOTAL=33


| Test | Tulemus | Rikkumisi |
|------|---------|-----------|
| `camp_name_gap_marketing_analytics` | WARN | 89 |
| `month_gaps_against_stg_analytics` | WARN | 8 |
| `month_gaps_against_stg_marketing` | WARN | 8 |
| `no_zombie_camp` | WARN | 38 |
| `not_null_external_lead_id_generate_lead_google` | WARN | 9 |
| `orphan_handshake_ext_lead_id_analytics_orders_fact_orders` | WARN | 1366 |
| `orphan_handshake_ext_trans_id_analytics_contracts_fact_contracts` | WARN | 1659 |


---

## Kuidas lugeda tulemusi?

**dbt tulemus (üks test, `Done.` rida):**

| Tulemus | Tähendus | Logi | Pipeline |
|---------|----------|------|----------|
| **PASS** | test läbib | `PASS=1 WARN=0 ERROR=0 TOTAL=1` | töötab edasi |
| **WARN** | hoiatus; testis `severity: warn` | `PASS=0 WARN=1 ERROR=0 TOTAL=1` | töötab edasi |
| **ERROR** | viga; testis `severity: error` | `PASS=0 WARN=0 ERROR=1 TOTAL=1` | pipeline lõpetab töö |

---

## Testide kirjeldused

### Staging (`dbt/models/staging`)

#### `negative_cost_stg_marketing`

| | |
|--|--|
| **Mudel** | `stg_marketing` |
| **Fail** | `dbt/models/staging/_stg__models.yml` |
| **Severity** | ERROR |
| **store_failures** | jah |
| **Mida testib** | veeru `cost` väärtus võib olla `0`, aga ei tohi olla negatiivne |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select negative_cost_stg_marketing` | `PASS=1 ERROR=0` |
| 2. Vigased read | `ERROR=1` | `docker compose run --rm -w /app/dbt etl dbt show --select negative_cost_stg_marketing --limit 20` | negatiivse `cost` read terminalis |
| 3. Audit | `ERROR=1` | `SELECT * FROM public_dbt_test__audit.negative_cost_stg_marketing LIMIT 20;` | sama read mis samm 2; PASS korral tühi |

---

#### `not_null_campaign_name_stg_marketing`

| | |
|--|--|
| **Mudel** | `stg_marketing` |
| **Fail** | `dbt/models/staging/_stg__models.yml` |
| **Severity** | WARN |
| **store_failures** | ei |
| **Mida testib** | `campaign_name` ei tohi olla NULL |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select not_null_campaign_name_stg_marketing` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select not_null_campaign_name_stg_marketing --limit 20` | read, kus `campaign_name` on NULL |

---

#### `not_null_external_lead_id_generate_lead_google`

| | |
|--|--|
| **Mudel** | `stg_analytics` |
| **Fail** | `dbt/models/staging/_stg__models.yml` |
| **Severity** | WARN |
| **store_failures** | ei |
| **Mida testib** | `event_name = 'generate_lead'` ja `utm_source = 'google'`: `external_lead_id` ei tohi olla NULL |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select not_null_external_lead_id_generate_lead_google` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select not_null_external_lead_id_generate_lead_google --limit 20` | read ilma `external_lead_id`-ta, kui allikaks 'google' |

---

#### `not_null_external_transaction_id_purchase_google`

| | |
|--|--|
| **Mudel** | `stg_analytics` |
| **Fail** | `dbt/models/staging/_stg__models.yml` |
| **Severity** | WARN |
| **store_failures** | ei |
| **Mida testib** | `event_name = 'purchase'` ja `utm_source = 'google'`: `external_transaction_id` ei tohi olla NULL |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select not_null_external_transaction_id_purchase_google` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select not_null_external_transaction_id_purchase_google --limit 20` | read ilma `external_transaction_id`-ta, kui allikaks 'google'|

---

#### `invalid_external_lead_id_generate_lead`

| | |
|--|--|
| **Mudel** | `stg_analytics` |
| **Fail** | `dbt/models/staging/_stg__models.yml` |
| **Severity** | WARN |
| **store_failures** | ei |
| **Mida testib** | `event_name = 'generate_lead'`: `external_lead_id` ei tohi olla `(not set)` ega `(none)` |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select invalid_external_lead_id_generate_lead` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select invalid_external_lead_id_generate_lead --limit 20` | `external_lead_id` on `(not set)` või `(none)` |

---

#### `unique_external_lead_id_generate_lead`

| | |
|--|--|
| **Mudel** | `stg_analytics` |
| **Fail** | `dbt/models/staging/_stg__models.yml` |
| **Severity** | WARN |
| **store_failures** | ei |
| **Mida testib** | `event_name = 'generate_lead'` ja `external_lead_id IS NOT NULL`: sama external_lead_id ei tohi korduda |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select unique_external_lead_id_generate_lead` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select unique_external_lead_id_generate_lead --limit 20` | sama `external_lead_id` kordub (>1 rida) |

---

#### `invalid_external_transaction_id_purchase`

| | |
|--|--|
| **Mudel** | `stg_analytics` |
| **Fail** | `dbt/models/staging/_stg__models.yml` |
| **Severity** | WARN |
| **store_failures** | ei |
| **Mida testib** | `event_name = 'purchase'`: `external_transaction_id` ei tohi olla `(not set)` ega `(none)` |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select invalid_external_transaction_id_purchase` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select invalid_external_transaction_id_purchase --limit 20` | `external_transaction_id` on `(not set)` või `(none)` |

---

#### `unique_external_transaction_id_purchase`

| | |
|--|--|
| **Mudel** | `stg_analytics` |
| **Fail** | `dbt/models/staging/_stg__models.yml` |
| **Severity** | WARN |
| **store_failures** | ei |
| **Mida testib** | `event_name = 'purchase'` ja `external_transaction_id IS NOT NULL`: sama `external_transaction_id` ei tohi korduda |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select unique_external_transaction_id_purchase` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select unique_external_transaction_id_purchase --limit 20` | sama `external_transaction_id` kordub (>1 rida) |

---

#### `unique_external_lead_id_stg_orders`

| | |
|--|--|
| **Mudel** | `stg_orders` |
| **Fail** | `dbt/models/staging/_stg__models.yml` |
| **Severity** | WARN |
| **store_failures** | ei |
| **Mida testib** | sama `external_lead_id` ei tohi `stg_orders`-is korduda (NULL-id välja) |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select unique_external_lead_id_stg_orders` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select unique_external_lead_id_stg_orders --limit 20` | sama `external_lead_id` kordub (>1 rida) |

---

#### `recency_stg_marketing_25_days`

| | |
|--|--|
| **Mudel** | `stg_marketing` |
| **Fail** | `dbt/models/staging/_stg__models.yml` |
| **Severity** | WARN |
| **store_failures** | ei |
| **Mida testib** | kas `stg_marketing`-is on vähemalt üks rida, mille `date_key` on vanem kui  **25 päeva** (`dbt_utils.recency`, `ignore_time_component: true`). Google Ads andmed laetakse käsitsi / proxy kaudu — 25 päeva on puhver. |

**Kontroll andmetes:**

```sql
SELECT MAX(date_key) AS viimane_kuupev,
       MAX(date_key) FILTER (WHERE cost > 0) AS viimane_kulupaev
FROM public_staging.stg_marketing;
```

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select recency_stg_marketing_25_days` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select recency_stg_marketing_25_days --limit 20` | aegunud või puuduv `date_key` |

---

#### `recency_stg_analytics_25_days`

| | |
|--|--|
| **Mudel** | `stg_analytics` |
| **Fail** | `dbt/models/staging/_stg__models.yml` |
| **Severity** | WARN |
| **store_failures** | ei |
| **Mida testib** | kas `stg_analytics`-is on vähemalt üks rida, mille `date_key` on viimase **25 päeva** jooksul. GA4 eksport laetakse käsitsi, umbes korra kuus.  |

**Kontroll andmetes:**

```sql
SELECT MAX(date_key) AS viimane_kuupev
FROM public_staging.stg_analytics;
```

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select recency_stg_analytics_25_days` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select recency_stg_analytics_25_days --limit 20` | aegunud või puuduv `date_key` |

---

#### `no_future_date` (generic)

| | |
|--|--|
| **Mudelid** | `stg_analytics`, `stg_marketing`, `stg_orders`, `stg_contracts`, `stg_leads` |
| **Fail** | `dbt/tests/generic/no_future_date.sql` · veeru test `_stg__models.yml`-is |
| **Severity** | ERROR |
| **store_failures** | ei |
| **Mida testib** | `date_key` ei tohi olla tulevikus (`cast(date_key as date) > current_date`) |

| dbt testi nimi | Mudel |
|----------------|-------|
| `no_future_date_stg_analytics_date_key` | `stg_analytics` |
| `no_future_date_stg_marketing_date_key` | `stg_marketing` |
| `no_future_date_stg_orders_date_key` | `stg_orders` |
| `no_future_date_stg_contracts_date_key` | `stg_contracts` |
| `no_future_date_stg_leads_date_key` | `stg_leads` |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus (kõik) | | `docker compose run --rm -w /app/dbt etl dbt test --select test_name:no_future_date` | `PASS=5 WARN=0 ERROR=0 TOTAL=5` |
| 2. Üks mudel | | `docker compose run --rm -w /app/dbt etl dbt test --select no_future_date_stg_marketing_date_key` | `PASS=1 ERROR=0` |
| 3. Vigased read | `ERROR=1` | `docker compose run --rm -w /app/dbt etl dbt show --select no_future_date_stg_analytics_date_key --limit 20` | tuleviku `date_key` read |

---

### Marts (`dbt/models/marts`)

#### `unique_fact_contracts_system_transaction_id`

| | |
|--|--|
| **Mudel** | `fact_contracts` |
| **Fail** | `dbt/models/marts/_marts__models.yml` |
| **Severity** | WARN |
| **store_failures** | ei |
| **Mida testib** | `system_transaction_id` peab `fact_contracts`-is olema unikaalne |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select unique_fact_contracts_system_transaction_id` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select unique_fact_contracts_system_transaction_id --limit 20` | sama `system_transaction_id` kordub (>1 rida) |
---

#### `unique_fact_orders_system_transaction_id`

| | |
|--|--|
| **Mudel** | `fact_orders` |
| **Fail** | `dbt/models/marts/_marts__models.yml` |
| **Severity** | WARN |
| **store_failures** | ei |
| **Mida testib** | `system_transaction_id` peab `fact_orders`-is olema unikaalne |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select unique_fact_orders_system_transaction_id` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select unique_fact_orders_system_transaction_id --limit 20` | sama `system_transaction_id` kordub (>1 rida) |

---

#### `not_null_fact_orders_system_transaction_id`

| | |
|--|--|
| **Mudel** | `fact_orders` |
| **Fail** | `dbt/models/marts/_marts__models.yml` |
| **Severity** | WARN |
| **store_failures** | ei |
| **Mida testib** | `system_transaction_id` ei tohi olla NULL |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select not_null_fact_orders_system_transaction_id` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select not_null_fact_orders_system_transaction_id --limit 20` | `system_transaction_id` on NULL |

---

#### `B2B_B2C_customer_segment_fact_orders`

| | |
|--|--|
| **Mudel** | `fact_orders` |
| **Fail** | `dbt/models/marts/_marts__models.yml` |
| **Severity** | WARN |
| **store_failures** | ei |
| **Mida testib** | `customer_segment` peab olema `b2b` või `b2c` (või NULL) |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select B2B_B2C_customer_segment_fact_orders` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select B2B_B2C_customer_segment_fact_orders --limit 20` | lubamatu `customer_segment` |
---

#### `lead_opportunity_gte_created_dim_lead`

| | |
|--|--|
| **Mudel** | `dim_lead` |
| **Fail** | `dbt/models/marts/_marts__models.yml` |
| **Severity** | WARN |
| **store_failures** | ei |
| **Mida testib** | `opportunity_at` ≥ `lead_created_at` (kui mõlemad täidetud) |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select lead_opportunity_gte_created_dim_lead` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select lead_opportunity_gte_created_dim_lead --limit 20` | `opportunity_at` < `lead_created_at` |
---
#### `lead_offer_gte_opportunity_dim_lead`

| | |
|--|--|
| **Mudel** | `dim_lead` |
| **Fail** | `dbt/models/marts/_marts__models.yml` |
| **Severity** | WARN |
| **store_failures** | ei |
| **Mida testib** | `offer_at` ≥ `opportunity_at` (kui mõlemad täidetud) |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select lead_offer_gte_opportunity_dim_lead` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select lead_offer_gte_opportunity_dim_lead --limit 20` | `offer_at` < `opportunity_at` |

---

#### `lead_quote_gte_offer_dim_lead`

| | |
|--|--|
| **Mudel** | `dim_lead` |
| **Fail** | `dbt/models/marts/_marts__models.yml` |
| **Severity** | WARN |
| **store_failures** | ei |
| **Mida testib** | `quote_at` ≥ `offer_at` (kui mõlemad täidetud) |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select lead_quote_gte_offer_dim_lead` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select lead_quote_gte_offer_dim_lead --limit 20` | `quote_at` < `offer_at` |

---

#### `lead_no_offer_without_opportunity_dim_lead`

| | |
|--|--|
| **Mudel** | `dim_lead` |
| **Fail** | `dbt/models/marts/_marts__models.yml` |
| **Severity** | WARN |
| **store_failures** | ei |
| **Mida testib** | ei tohi olla `offer_at` ilma `opportunity_at` |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select lead_no_offer_without_opportunity_dim_lead` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select lead_no_offer_without_opportunity_dim_lead --limit 20` | `offer_at` täidetud, `opportunity_at` NULL |

---

#### `lead_no_quote_without_offer_dim_lead`

| | |
|--|--|
| **Mudel** | `dim_lead` |
| **Fail** | `dbt/models/marts/_marts__models.yml` |
| **Severity** | WARN |
| **store_failures** | ei |
| **Mida testib** | ei tohi olla `quote_at` ilma `offer_at` |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select lead_no_quote_without_offer_dim_lead` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select lead_no_quote_without_offer_dim_lead --limit 20` | `quote_at` täidetud, `offer_at` NULL |

---

### Singular (`dbt/tests`)

#### `camp_name_gap_marketing_analytics`

| | |
|--|--|
| **Mudel** | `stg_marketing`, `stg_analytics` |
| **Fail** | `dbt/tests/camp_name_gap_marketing_analytics.sql` |
| **Severity** | WARN |
| **store_failures** | jah |
| **Mida testib** | kampaanianime kattuvus mõlemas suunas (täpne `campaign_name`; `missing_in_analytics` / `missing_in_marketing`) |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select camp_name_gap_marketing_analytics` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select camp_name_gap_marketing_analytics --limit 20` | gap-read `direction` veeruga |
| 3. Audit | `WARN=1` | `SELECT * FROM public_dbt_test__audit.camp_name_gap_marketing_analytics LIMIT 20;` | sama mis samm 2 |

---

#### `camp_name_case_mismatch_marketing_analytics`

| | |
|--|--|
| **Mudel** | `stg_marketing`, `stg_analytics` |
| **Fail** | `dbt/tests/camp_name_case_mismatch_marketing_analytics.sql` |
| **Severity** | WARN |
| **store_failures** | jah |
| **Mida testib** | sama kampaania erinev kirjapilt (`trim(lower(...))` klapib, raw nimi erineb) |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select camp_name_case_mismatch_marketing_analytics` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select camp_name_case_mismatch_marketing_analytics --limit 20` | `normalized_name`, `variants` |
| 3. Audit | `WARN=1` | `SELECT * FROM public_dbt_test__audit.camp_name_case_mismatch_marketing_analytics LIMIT 20;` | sama mis samm 2 |

---

#### Näited

| Marketing | Analytics | Gap-test | Case-test |
|-----------|-----------|----------|-----------|
| `Summer_Sale` | `summer_sale` | WARN (täpne string ei klapi) | **WARN** — 2 varianti, `normalized_name = summer_sale` |
| `Summer_Sale` | *(puudub)* | WARN (`missing_in_analytics`) | **PASS** — ainult 1 variant kogu andmestikus |
| `Summer_Sale` + `summer_sale` | *(mõlemad `stg_marketing`)* | WARN | **WARN** — variandid samas allikas |
| `summer_sale` | `summer_sale` | PASS | PASS |

---

#### Gap vs case (lühidalt)

| | **gap** | **case** |
|---|--------|--------|
| Küsimus | kas nimi **puudub** teises allikas? | kas **sama** nimi on **erineva suurusega**? |
| Võrdlus | täpne `campaign_name` | `trim(lower(...))` |
| Suund | jah — `missing_in_analytics` / `missing_in_marketing` | ei — ühine kontroll |

---

#### `no_ghost_camp`

| | |
|--|--|
| **Mudel** | `stg_marketing`, `stg_analytics` |
| **Fail** | `dbt/tests/no_ghost_camp.sql` |
| **Severity** | WARN |
| **store_failures** | jah |
| **Mida testib** | `stg_marketing` on kulu (`cost > 0`), `stg_analytics` pole vastavat kampaaniat samas riigis |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select no_ghost_camp` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select no_ghost_camp --limit 20` | `campaign_name`, `wasted_spend` |
| 3. Audit | `WARN=1` | `SELECT * FROM public_dbt_test__audit.no_ghost_camp LIMIT 20;` | sama mis samm 2 |

---
#### `no_zombie_camp`

| | |
|--|--|
| **Mudel** | `stg_analytics`, `stg_marketing` |
| **Fail** | `dbt/tests/no_zombie_camp.sql` |
| **Severity** | WARN |
| **store_failures** | jah |
| **Mida testib** | analyticsis on tasuline liiklus, marketingus pole vastavat kampaaniat samas riigis |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select no_zombie_camp` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select no_zombie_camp --limit 20` | `session_count`, utm veerud |
| 3. Audit | `WARN=1` | `SELECT * FROM public_dbt_test__audit.no_zombie_camp LIMIT 20;` | sama mis samm 2 |

---
#### `orphan_handshake_ext_lead_id_analytics_orders_fact_orders`

| | |
|--|--|
| **Mudel** | `stg_analytics`, `stg_orders`, `fact_orders` |
| **Fail** | `dbt/tests/orphan_handshake_ext_lead_id_analytics_orders_fact_orders.sql` |
| **Severity** | WARN |
| **store_failures** | jah |
| **Mida testib** | `external_lead_id` (`generate_lead`) peab olema analytics → orders → fact_orders ahelas |

| `gap_status` | Tähendus |
|--------------|----------|
| `In Analytics -> Missing in Orders` | `external_lead_id` on `stg_analytics`, puudub `stg_orders` |
| `In Orders -> Missing in Analytics` | `external_lead_id` on `stg_orders`, puudub `stg_analytics` |
| `In Orders -> Missing in fact_orders` | `external_lead_id` on `stg_orders`, puudub `fact_orders` |
| `Other handshake gap` | muu katkestus — ülejäänud kombinatsioonid, mida ülalolevad read ei kata (nt `external_lead_id` ainult `fact_orders`) |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select orphan_handshake_ext_lead_id_analytics_orders_fact_orders` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select orphan_handshake_ext_lead_id_analytics_orders_fact_orders --limit 20` | `external_lead_id`, `gap_status` |
| 3. Audit | `WARN=1` | `SELECT * FROM public_dbt_test__audit.orphan_handshake_ext_lead_id_analytics_orders_fact_orders LIMIT 20;` | sama mis samm 2 |

---
#### `orphan_handshake_ext_trans_id_analytics_contracts_fact_contracts`

| | |
|--|--|
| **Mudel** | `stg_analytics`, `stg_contracts`, `fact_contracts` |
| **Fail** | `dbt/tests/orphan_handshake_ext_trans_id_analytics_contracts_fact_contracts.sql` |
| **Severity** | WARN |
| **store_failures** | jah (alias) |
| **Mida testib** | `external_transaction_id` (`purchase`) peab olema analytics → contracts → fact_contracts ahelas |

| `gap_status` | Tähendus |
|--------------|----------|
| `In Analytics -> Missing in Contracts` | `external_transaction_id` on `stg_analytics`, puudub `stg_contracts` |
| `In Contracts -> Missing in Analytics` | `external_transaction_id` on `stg_contracts`, puudub `stg_analytics` |
| `In Contracts -> Missing in fact_contracts` | `external_transaction_id` on `stg_contracts`, puudub `fact_contracts` |
| `Other handshake gap` | muu katkestus — ülejäänud kombinatsioonid, mida ülalolevad read ei kata (nt `external_transaction_id` ainult `fact_contracts`) |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select orphan_handshake_ext_trans_id_analytics_contracts_fact_contracts` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select orphan_handshake_ext_trans_id_analytics_contracts_fact_contracts --limit 20` | `external_transaction_id`, `gap_status` |
| 3. Audit | `WARN=1` | `SELECT * FROM public_dbt_test__audit.orphan_hs_ext_trans_id_analytics_contracts_fc LIMIT 20;` | lühendatud audit-tabeli nimi |

---

#### `month_gaps_against_stg_marketing`

| | |
|--|--|
| **Mudel** | `stg_marketing`, `stg_analytics`, `stg_orders`, `stg_contracts` |
| **Fail** | `dbt/tests/month_gaps_against_stg_marketing.sql` |
| **Severity** | WARN |
| **store_failures** | jah |
| **Mida testib** | kuu-põhised lüngad, kus ühes staging-tabelis on kuus ridu, partner-tabelis samas kuus 0 rida. ***`stg_marketing`*** võrdluse aluseks.|

| `gap_status` (näited) | Tähendus |
|-----------------------|----------|
| `In Marketing -> Missing in Analytics` | kuu on `stg_marketing`, aga puudub `stg_analytics` |
| `In Analytics -> Missing in Marketing` | kuu on `stg_analytics`, aga puudub `stg_marketing` |
| `In Marketing -> Missing in Orders` | kuu on `stg_marketing`, aga puudub `stg_orders` |
| `In Orders -> Missing in Marketing` | kuu on `stg_orders`, aga puudub `stg_marketing` |
| `In Marketing -> Missing in Contracts` | kuu on `stg_marketing`, aga puudub `stg_contracts` |
| `In Contracts -> Missing in Marketing` | kuu on `stg_contracts`, aga puudub `stg_marketing` |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select month_gaps_against_stg_marketing` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select month_gaps_against_stg_marketing --limit 20` | `month_start`, `left_table`, `right_table`, `gap_status` |
| 3. Audit | `WARN=1` | `SELECT * FROM public_dbt_test__audit.month_gaps_against_stg_marketing LIMIT 20;` | sama mis samm 2 |

---

#### `month_gaps_against_stg_analytics`

| | |
|--|--|
| **Mudel** | `date_coverage_gaps_by_month` (monitooring; vaatab `stg_marketing`, `stg_analytics`, `stg_orders`, `stg_contracts`) |
| **Fail** | `dbt/tests/month_gaps_against_stg_analytics.sql` · loogika `dbt/models/monitoring/date_coverage_gaps_by_month.sql` |
| **Severity** | WARN |
| **store_failures** | jah |
| **Mida testib** | kuu-põhised lüngad, kus ühes staging-tabelis on kuus ridu, partner-tabelis samas kuu 0 rida — **stg_analytics** vastu |

| `gap_status` (näited) | Tähendus |
|-----------------------|----------|
| `In Analytics -> Missing in Marketing` | kuu on `stg_analytics`, aga puudub `stg_marketing` |
| `In Analytics -> Missing in Orders` | kuu on `stg_analytics`, aga puudub `stg_orders` |
| `In Analytics -> Missing in Contracts` | kuu on `stg_analytics`, aga puudub `stg_contracts` |
| `In Orders -> Missing in Analytics` | kuu on `stg_orders`, aga puudub `stg_analytics` |
| `In Contracts -> Missing in Analytics` | kuu on `stg_contracts`, aga puudub `stg_analytics` |
| `In Marketing -> Missing in Analytics` | kuu on `stg_marketing`, aga puudub `stg_analytics` |

| Samm | Millal | Käsk | Oodatud |
|------|--------|------|---------|
| 1. Käivitus | | `docker compose run --rm -w /app/dbt etl dbt test --select month_gaps_against_stg_analytics` | `PASS=1 WARN=0` |
| 2. Vigased read | `WARN=1` | `docker compose run --rm -w /app/dbt etl dbt show --select month_gaps_against_stg_analytics --limit 20` | `month_start`, `left_table`, `right_table`, `gap_status` |
| 3. Audit | `WARN=1` | `SELECT * FROM public_dbt_test__audit.month_gaps_against_stg_analytics LIMIT 20;` | sama mis samm 2 |

---

## Monitooring (`dbt/models/monitoring/`)

Mudelid dubleerivad 3 singular-testi loogikat (**orphan handshake**, **kuude lüngad**). Tulemusi saab vaadata **SQL Lab-is** või **BI-s** (nt Superset) ilma `dbt test` uuesti käivitamata — piisab, kui `dbt run` on monitooringu mudelid üles ehitanud.

| Mudel | Seotud test |
|-------|-------------|
| `orphan_handshake_ext_lead_id_analytics_orders_fact_orders` | `orphan_handshake_ext_lead_id_analytics_orders_fact_orders` |
| `orphan_handshake_ext_trans_id_analytics_contracts_fact_contracts` | `orphan_handshake_ext_trans_id_analytics_contracts_fact_contracts` |
| `date_coverage_gaps_by_month` | `month_gaps_against_stg_marketing`, `month_gaps_against_stg_analytics` |

**Püsivad monitooringu tabelid** (`public`):

```sql
SELECT * FROM public.orphan_handshake_ext_lead_id_analytics_orders_fact_orders LIMIT 20;

SELECT * FROM public.orphan_handshake_ext_trans_id_analytics_contracts_fact_contracts LIMIT 20;

SELECT * FROM public.date_coverage_gaps_by_month ORDER BY month_start LIMIT 20;
```
