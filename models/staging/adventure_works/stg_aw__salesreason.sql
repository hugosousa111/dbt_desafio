with source_data as (
    select
        salesreasonid
        , name as salesreasonname
        , reasontype
    from {{ source('adventure_works', 'salesreason') }}
)
select *
from source_data