with source_data as (
    select
        salesorderid
        , salesreasonid
    from {{ source('adventure_works', 'salesorderheadersalesreason') }}
)
select *
from source_data