with 
    stg_salesorderheader as (
        select
            salesorderid
            , orderdate
            , orderstatus
            , customerid
            , creditcardid
            , shiptoaddressid
        from {{ ref('stg_aw__salesorderheader') }}
    ),
    stg_salesorderdetail as (
        select
            salesorderdetailid
            , salesorderid
            , orderqty
            , productid
            , unitprice
        from {{ ref('stg_aw__salesorderdetail') }}
    ),
    stg_salesorderheadersalesreason as (
        select
            salesorderid
            , salesreasonid
        from {{ ref('stg_aw__salesorderheadersalesreason') }}
    ),
    dim_creditcards as (
        select
            creditcards_sk
            , creditcardid
        from {{ ref('dim_creditcards') }}
    ), 
    dim_customers as (
        select
            customers_sk
            , customerid
        from {{ ref('dim_customers') }}
    ), 
    dim_datesales as (
        select
            datesales_sk
            , orderdate
        from {{ ref('dim_datesales') }}
    ), 
    dim_locations as (
        select
            locations_sk
            , shiptoaddressid
        from {{ ref('dim_locations') }}
    ), 
    dim_products as (
        select
            products_sk
            , productid
        from {{ ref('dim_products') }}
    ), 
    dim_statussales as (
        select
            statussales_sk	
            , orderstatus
        from {{ ref('dim_statussales') }}
    ), 
    -- The dim_salesreason is a particular case
    -- There are sales with more than one reason
    -- To solve this problem, the names and types
    ---- of reasons were aggregated into a string
    ---- separated by |, and inserted directly 
    ---- into the fact.
    dim_salesreason as (
        select
            salesreason_sk
            , salesreasonid
            , salesreasonname
            , reasontype
        from {{ ref('dim_salesreason') }}
    ), 
    expanded_dim_salesreason as (
        select
            stg_salesorderheadersalesreason.salesorderid
            , stg_salesorderheadersalesreason.salesreasonid
            , dim_salesreason.salesreason_sk
            , dim_salesreason.salesreasonname
            , dim_salesreason.reasontype
        from stg_salesorderheadersalesreason
        left join dim_salesreason on stg_salesorderheadersalesreason.salesreasonid = dim_salesreason.salesreasonid
    ),
    agg_expanded_dim_salesreason as (
        select
            expanded_dim_salesreason.salesorderid
            , string_agg(expanded_dim_salesreason.salesreasonname, ' | ') as salesreasonname_agg
            , string_agg(expanded_dim_salesreason.reasontype, ' | ') as reasontype_agg
        from expanded_dim_salesreason
        group by expanded_dim_salesreason.salesorderid
    ),
    expanded_salesorderheader as (
        select 
            stg_salesorderheader.salesorderid
            , dim_creditcards.creditcards_sk
            , dim_customers.customers_sk
            , dim_datesales.datesales_sk
            , dim_locations.locations_sk
            , agg_expanded_dim_salesreason.salesreasonname_agg
            , agg_expanded_dim_salesreason.reasontype_agg
            , dim_statussales.statussales_sk
        from stg_salesorderheader
        left join dim_datesales on stg_salesorderheader.orderdate = dim_datesales.orderdate
        left join dim_statussales on stg_salesorderheader.orderstatus = dim_statussales.orderstatus
        left join dim_customers on stg_salesorderheader.customerid = dim_customers.customerid
        left join dim_creditcards on stg_salesorderheader.creditcardid = dim_creditcards.creditcardid
        left join dim_locations on stg_salesorderheader.shiptoaddressid = dim_locations.shiptoaddressid
        left join agg_expanded_dim_salesreason on stg_salesorderheader.salesorderid = agg_expanded_dim_salesreason.salesorderid
    ),
    expanded_salesorderdetail as (
        select
            stg_salesorderdetail.salesorderdetailid
            , stg_salesorderdetail.salesorderid
            , stg_salesorderdetail.orderqty
            , stg_salesorderdetail.unitprice
            , dim_products.products_sk
        from stg_salesorderdetail
        left join dim_products on stg_salesorderdetail.productid = dim_products.productid
    ),
    transformed as (
        select
            expanded_salesorderdetail.salesorderdetailid
            , expanded_salesorderdetail.salesorderid            
            , expanded_salesorderdetail.products_sk
            , expanded_salesorderheader.creditcards_sk
            , expanded_salesorderheader.customers_sk
            , expanded_salesorderheader.datesales_sk
            , expanded_salesorderheader.locations_sk
            , expanded_salesorderheader.salesreasonname_agg
            , expanded_salesorderheader.reasontype_agg
            , expanded_salesorderheader.statussales_sk
            , expanded_salesorderdetail.orderqty
            , expanded_salesorderdetail.unitprice
            , expanded_salesorderdetail.orderqty * expanded_salesorderdetail.unitprice as totalvalue
        from expanded_salesorderdetail 
        left join expanded_salesorderheader on expanded_salesorderdetail.salesorderid = expanded_salesorderheader.salesorderid
    )
select *
from transformed