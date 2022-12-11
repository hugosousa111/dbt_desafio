with 
    stg_salesreason as (
        select
            salesreasonid
            , salesreasonname
            , reasontype
        from {{ ref('stg_aw__salesreason') }}
    ),
    stg_salesorderheadersalesreason as (
        select
            distinct salesreasonid
        from {{ ref('stg_aw__salesorderheadersalesreason') }}
    ),
    transformed as (
        select 
            row_number() over (order by stg_salesorderheadersalesreason.salesreasonid) as salesreason_sk -- auto-incremental surrogate key	
            , stg_salesorderheadersalesreason.salesreasonid
            , stg_salesreason.salesreasonname
            , stg_salesreason.reasontype
        from stg_salesorderheadersalesreason 
        left join stg_salesreason on stg_salesorderheadersalesreason.salesreasonid = stg_salesreason.salesreasonid
    )
select *
from transformed

