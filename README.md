[Andmeinseneeria kursuse](https://github.com/KristoR/ut-andmeinseneeria-2026) grupitöö eesmärgiks oli luua terviklik andmelahendus, mis integreerib turundusinvesteeringud, veebianalüütika, CRM-i müügivihjed ja tellimused ning iseteeninduse lepingute andmed. Nii saab täpsemalt hinnata turundusinvesteeringute tasuvust.

Minu ülesandeks oli dbt-s testide kirjutamine. 
-[_marts_models.yml](https://github.com/AnuVi/dbt-tests/blob/main/_marts_models.yml) ja [_stg_models.yml](https://github.com/AnuVi/dbt-tests/blob/main/_stg_models.yml) sisaldavad katkendeid üld(generic)testidest, mis kontrollivad ühe tabeli/mudeli veerge.
- Kirjutatud singular-testid leiab [kaustast](https://github.com/AnuVi/dbt-tests/tree/main/dbt/tests). Need testid sisaldavad ühte päringut, mis kontrollib üle mitme tabeli.
- [Dokumentatsioon testide kohta](https://github.com/AnuVi/dbt-tests/blob/main/testid.md). 
- [Jupp lõputöö videost](https://www.anuvi.me/demos/videos/dbt-test.mp4), kus tutvustan nõutud kolme andmekvaliteedi testi.


| Tüüp                                      | Idee                                                                                                                   |
| ----------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `unique` / `not_null`                     | Võtmed ja kohustuslikud väljad peavad olema unikaalsed ja ei tohi olla tühjad                                          |
| `not_null` + `where`                      | Kohustuslik ainult tingimuse korral                                                                  |
| `unique` + `where`                        | Unikaalsus ainult tingimuse korral                                                                                  |
| `accepted_values`                         | Veerg võib olla ainult kindlate väärtuste hulgast                                                                      |
| `relationships`                           | Fakt/dim viitab teisele tabelile (FK)                                                                                  |
| `dbt_utils.recency`                       | Viimane `date_key` peab olema piisavalt värske (25 päeva)                                                              |
| `dbt_utils.expression_is_true`            | Avaldis peab kehtima nt `cost >= 0`                                                                                    |
| `dbt_expectations`                        | Võrdleb **kahte veergu** samal real — nt `opportunity_at` ≥ `lead_created_at`: `dim_lead`: kuupäevad õiges järjekorras |
| `dbt_utils.not_null_pDroportion`          | Võib tühi olla, kui nt 65–90% veerust on täidetud                                |
| `dbt_utils.unique_combination_of_columns` | Mitu veergu koos unikaalsed                                      


--------------------------------------------------------------------------------------------------------------------------------------------------------------------





The goal of the [data engineering course](https://github.com/KristoR/ut-andmeinseneeria-2026) group project was to build a complete data solution that integrates marketing investments, web analytics, CRM leads and orders, and self-service contract data. This makes it possible to assess the return on marketing investment more precisely.

My task was to write tests in dbt.
- [Documentation of the tests](https://github.com/AnuVi/dbt-tests/blob/main/testid.md).
- The singular tests are in [this folder](https://github.com/AnuVi/dbt-tests/tree/main/dbt/tests).
- [A clip from the final project video in Estonian](https://www.anuvi.me/demos/videos/dbt-test.mp4), where I introduce the three required data quality tests.

| Type | Idea |
| --- | --- |
| `unique` / `not_null` | Keys and required fields must be unique and must not be empty |
| `not_null` + `where` | Required only when a condition is met |
| `unique` + `where` | Uniqueness only when a condition is met |
| `accepted_values` | A column may contain only values from a fixed set |
| `relationships` | A fact or dimension table references another table (FK) |
| `dbt_utils.recency` | The latest `date_key` must be recent enough (25 days) |
| `dbt_utils.expression_is_true` | An expression must hold, e.g. `cost >= 0` |
| `dbt_expectations` | Compares **two columns** on the same row — e.g. `opportunity_at` ≥ `lead_created_at` on `dim_lead`: dates in the correct order |
| `dbt_utils.not_null_proportion` | May be empty if, for example, 65–90% of the column is filled |
| `dbt_utils.unique_combination_of_columns` | Several columns together are unique |

