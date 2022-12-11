with source_data as (
    select
        addressid
        , city
        , stateprovinceid
    from {{ source('adventure_works', 'address') }}
)
select *
from source_data