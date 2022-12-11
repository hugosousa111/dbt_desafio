with 
    stg_salesorderheader as (
        select 
            distinct orderstatus
        from {{ ref('stg_aw__salesorderheader') }}
    ),
    expanded as (
        SELECT 
            orderstatus
            , CASE 
                WHEN orderstatus = 1 THEN 'In process'
                WHEN orderstatus = 2 THEN 'Approved'
                WHEN orderstatus = 3 THEN 'Backordered'
                WHEN orderstatus = 4 THEN 'Rejected'
                WHEN orderstatus = 5 THEN 'Shipped'
                WHEN orderstatus = 6 THEN 'Cancelled' 
            end as statusdescription
        from stg_salesorderheader
    ),
    transformed as (
        select 
            row_number() over (order by expanded.orderstatus) as statussales_sk -- auto-incremental surrogate key	
            , expanded.orderstatus
            , expanded.statusdescription
        from expanded
    )
select *
from transformed