with 
    stg_customer as (
        select
            customerid
            , personid
        from {{ ref('stg_aw__customer') }}
    ),
    stg_person as (
        select
            businessentityid
            , namestyle
            , firstname
            , middlename
            , lastname
        from {{ ref('stg_aw__person') }}
    ),
    customer_join_person as (
        select
            stg_customer.customerid
            , stg_customer.personid
            , stg_person.namestyle
            , stg_person.firstname
            , stg_person.middlename
            , stg_person.lastname
        from stg_customer
        left join stg_person on stg_customer.personid = stg_person.businessentityid
    ),
    stg_salesorderheader as (
        select 
            distinct customerid
        from {{ ref('stg_aw__salesorderheader') }}
        where customerid is not null
    ),
    transformed as (
        select 
            row_number() over (order by stg_salesorderheader.customerid) as customers_sk -- auto-incremental surrogate key	
            , stg_salesorderheader.customerid
            , customer_join_person.personid
            , customer_join_person.namestyle
            , customer_join_person.firstname
            , customer_join_person.middlename
            , customer_join_person.lastname
            , concat(customer_join_person.firstname, ' ', ifnull(customer_join_person.middlename,''), ' ', customer_join_person.lastname) as fullname
        from stg_salesorderheader 
        left join customer_join_person on stg_salesorderheader.customerid = customer_join_person.customerid
    )
select *
from transformed