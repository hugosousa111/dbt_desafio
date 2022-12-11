with 
    stg_creditcard as (
        select 
            creditcardid
            , cardtype
        from {{ ref('stg_aw__creditcard') }}
    ),
    stg_salesorderheader as (
        select 
            distinct creditcardid
        from {{ ref('stg_aw__salesorderheader') }}
        where creditcardid is not null
    ),     
    transformed as (
        select 
            row_number() over (order by stg_salesorderheader.creditcardid) as creditcards_sk -- auto-incremental surrogate key	
            , stg_salesorderheader.creditcardid
            , stg_creditcard.cardtype
        from stg_salesorderheader 
        left join stg_creditcard on stg_salesorderheader.creditcardid = stg_creditcard.creditcardid
    )
select *
from transformed