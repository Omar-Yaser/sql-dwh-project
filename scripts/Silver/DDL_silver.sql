/*
------------------------------------------------------------------------------------------------
DDL Script : Silver Tables 
------------------------------------------------------------------------------------------------
Script Purpose :
 - This Script creates 6 tables in schema ('silver')
 - 3 tables for crm files 
 - 3 tables for erp files
------------------------------------------------------------------------------------------------
*/
create table silver.crm_cust_info (
cst_id int ,
cst_key nvarchar(50),
cst_firstname nvarchar(50),
cst_lastname nvarchar(50),
cst_marital_status nvarchar(10),
cst_gndr nvarchar(20) ,
cst_create_date date ,
dwh_create_date datetime2 default getdate()
);

GO

create table silver.crm_prd_info (

prd_id int,
cat_id nvarchar(50),
prd_key nvarchar(50),
prd_nm nvarchar(50),
prd_cost int,
prd_line nvarchar(50),
prd_start_dt date,
prd_end_dt date,
dwh_create_date datetime2 default getdate()

);

GO

create table silver.crm_sales_details
(
sls_ord_num nvarchar(50),
sls_prd_key nvarchar(50),
sls_cust_id int,
sls_order_dt date,
sls_ship_dt date,
sls_due_dt date,
sls_sales int,
sls_quantity int,
sls_price int,
dwh_create_date datetime2 default getdate()

) 

GO

create table silver.erp_cust_az12
(
CID nvarchar(50),
BDATE date,
GEN nvarchar(20),
dwh_create_date datetime2 default getdate()

)

GO


create table silver.erp_loc_a101
(
CID nvarchar(50),
CNTRY nvarchar(50) ,
dwh_create_date datetime2 default getdate()

)

GO


create table silver.erp_px_cat_g1v2
(
ID nvarchar(50),
CAT nvarchar(50),
SUBCAT nvarchar(50),
MAINTENANCE nvarchar(20),
dwh_create_date datetime2 default getdate()

)
