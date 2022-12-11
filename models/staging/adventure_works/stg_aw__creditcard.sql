with source_data as (
    select
        creditcardid
        , cardtype
    from {{ source('adventure_works', 'creditcard') }}
)
select *
from source_data