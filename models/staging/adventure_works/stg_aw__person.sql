with source_data as (
    select
        businessentityid
        , namestyle
        , firstname
        , middlename
        , lastname
    from {{ source('adventure_works', 'person') }}
)
select *
from source_data