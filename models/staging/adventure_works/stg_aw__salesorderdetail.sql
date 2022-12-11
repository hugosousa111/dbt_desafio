with source_data as (
    select
        salesorderdetailid
        , salesorderid
        , orderqty
        , productid
        , unitprice
    from {{ source('adventure_works', 'salesorderdetail') }}
)
select *
from source_data