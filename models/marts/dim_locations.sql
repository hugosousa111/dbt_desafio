with 
    stg_address as (
        select
            addressid
            , city
            , stateprovinceid
        from {{ ref('stg_aw__address') }}
    ),
    stg_stateprovince as (
        select
            stateprovinceid
            , countryregioncode
            , stateprovincename
        from {{ ref('stg_aw__stateprovince') }}
    ),
    stg_countryregion as (
        select
            countryregioncode
            , countryname
        from {{ ref('stg_aw__countryregion') }}
    ), 
    stg_salesorderheader as (
        select 
            distinct shiptoaddressid
        from {{ ref('stg_aw__salesorderheader') }}
    ),
    transformed as (
        select
            row_number() over (order by stg_salesorderheader.shiptoaddressid) as locations_sk -- auto-incremental surrogate key
            , stg_salesorderheader.shiptoaddressid
            , stg_address.city
            , stg_address.stateprovinceid
            , stg_stateprovince.stateprovincename
            , stg_stateprovince.countryregioncode
            , stg_countryregion.countryname
        from stg_salesorderheader
        left join stg_address on stg_salesorderheader.shiptoaddressid = stg_address.addressid
        left join stg_stateprovince on stg_address.stateprovinceid = stg_stateprovince.stateprovinceid
        left join stg_countryregion on stg_stateprovince.countryregioncode = stg_countryregion.countryregioncode
    )
select *
from transformed