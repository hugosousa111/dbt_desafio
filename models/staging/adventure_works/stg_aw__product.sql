with source_data as (
    select
        productid
        , name as productname
    from {{ source('adventure_works', 'product') }}
)
select *
from source_data