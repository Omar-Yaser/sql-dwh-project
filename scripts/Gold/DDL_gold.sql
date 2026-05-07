/*
DDL Script: Create Gold Views
------------------------------------------------------------------------------
Script Purpose:
    -This script creates views for the Gold layer in the data warehouse. 
    -The Gold layer represents the final dimension and fact tables (Star Schema)
    
    -Each view performs transformations and combines data from the Silver layer 
     to produce a clean, enriched, and business-ready dataset.
------------------------------------------------------------------------------
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
create view gold.dim_customers as 
(
select ROW_NUMBER() over (order by cst_id) as customer_key
, cst_id as customer_id
, cst_key as customer_number
, cst_firstname as first_name
, cst_lastname as last_name
, CNTRY as country
, cst_marital_status as marital_status
, case when cst_gndr !='n/a' then cst_gndr 
else isnull(GEN,'n/a') end as gender
, BDATE as birth_date
, cst_create_date as create_date
from 
silver.crm_cust_info c_c_i left join silver.erp_cust_az12 e_c_az 
on c_c_i.cst_key=e_c_az.CID
left join silver.erp_loc_a101 e_l_a on c_c_i.cst_key=e_l_a.CID
)
-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
create view gold.dim_products as 
(
select ROW_NUMBER() over (order by prd_start_dt, prd_key) as product_key
, prd_id as product_id
, prd_key as product_number
, prd_nm as product_name
, prd_cost as cost
, prd_line as product_line
, prd_start_dt as start_date
, cat_id as category_id
, isnull(CAT,'n/a') as category
, isnull(SUBCAT,'n/a') as subcategory
, isnull(MAINTENANCE,'n/a')  as maintenance
from
silver.crm_prd_info c_p_i left join silver.erp_px_cat_g1v2 e_p_c 
on c_p_i.cat_id = e_p_c.ID
where prd_end_dt is null
)
-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
create view gold.fact_sales as 
(
select ROW_NUMBER() over (order by sls_order_dt , sls_ord_num) as sales_key ,
customer_key ,
product_key ,
sls_ord_num as order_number ,
sls_order_dt as order_date ,
sls_ship_dt as ship_date ,
sls_due_dt as due_date,
sls_quantity as quantity ,
sls_price as price ,
sls_sales as sales
from
silver.crm_sales_details sd left join gold.dim_customers dc 
on sd.sls_cust_id=dc.customer_id 
left join gold.dim_products dp on sd.sls_prd_key=dp.product_number 
)
