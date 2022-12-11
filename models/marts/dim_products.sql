with 
    stg_product as (
        select
            productid
            , productname
        from {{ ref('stg_aw__product') }}
    ),
    stg_salesorderdetail as (
        select
            distinct productid
        from {{ ref('stg_aw__salesorderdetail') }}
    ),
    transformed as (
        select 
            row_number() over (order by stg_salesorderdetail.productid) as products_sk -- auto-incremental surrogate key	
            , stg_salesorderdetail.productid
            , stg_product.productname
        from stg_salesorderdetail 
        left join stg_product on stg_salesorderdetail.productid = stg_product.productid
    )
select *
from transformed