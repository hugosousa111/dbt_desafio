with source_data as (
    select
        customerid
        , personid
    from {{ source('adventure_works', 'customer') }}
)
select *
from source_data