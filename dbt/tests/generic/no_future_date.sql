{% test no_future_date(model, column_name) %}
select *
from {{ model }}
where {{ column_name }} is not null
  and cast({{ column_name }} as date) > current_date
{% endtest %}


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
