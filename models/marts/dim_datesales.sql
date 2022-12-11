with 
    stg_salesorderheader as (
        select 
            distinct orderdate
        from {{ ref('stg_aw__salesorderheader') }}
    ),
    date_expanded as (
        select 
            orderdate
            , EXTRACT(year FROM orderdate) as saleyear
            , EXTRACT(month FROM orderdate) as salemonth
            , EXTRACT(day FROM orderdate) as saleday
        from stg_salesorderheader
    ),
    transformed as (
        select 
            row_number() over (order by date_expanded.orderdate) as datesales_sk -- auto-incremental surrogate key	
            , date_expanded.orderdate
            , date_expanded.saleyear
            , date_expanded.salemonth
            , date_expanded.saleday
        from date_expanded
    )
select *
from transformed