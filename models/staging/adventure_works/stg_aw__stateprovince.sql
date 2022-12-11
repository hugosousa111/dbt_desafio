with source_data as (
    select
        stateprovinceid
        , countryregioncode
        , name as stateprovincename
    from {{ source('adventure_works', 'stateprovince') }}
)
select *
from source_data