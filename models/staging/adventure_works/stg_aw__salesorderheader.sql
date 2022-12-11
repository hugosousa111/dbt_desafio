with source_data as (
    select
        salesorderid
        , orderdate
        , status as orderstatus
        , customerid
        , creditcardid
        , shiptoaddressid
    from {{ source('adventure_works', 'salesorderheader') }}
)
select *
from source_data