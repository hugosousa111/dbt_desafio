with 
    fct_sales as (
        select 
            datesales_sk
            , totalvalue
        from {{ ref('fct_sales') }}
    ),
    dim_datesales as (
        select 
            datesales_sk
            , orderdate
        from {{ ref('dim_datesales') }}
    ),
    expanded_fct_sales as (
        select 
            fct_sales.datesales_sk
            , fct_sales.totalvalue
            , dim_datesales.orderdate
        from fct_sales
        left join dim_datesales on fct_sales.datesales_sk = dim_datesales.datesales_sk
    ),
    sales_first_quarter_2012 as (
        select 
            sum(totalvalue) as totalvalue_quarter 
        from expanded_fct_sales
        where orderdate between '2012-01-01' and '2012-03-31' 
    )
select * 
from sales_first_quarter_2012
where totalvalue_quarter not between 8422528 and 8422529
