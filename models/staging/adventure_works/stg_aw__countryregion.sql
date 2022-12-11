with source_data as (
    select
        countryregioncode
        , name as countryname
    from {{ source('adventure_works', 'countryregion') }}
)
select *
from source_data