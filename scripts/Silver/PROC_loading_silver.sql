/*
Stored Procedure : Loading Silver Layer ( Bronze -> Silver )
---------------------------------------------------------------------
Script Purpose :
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables. 
*/
CREATE OR ALTER PROC silver.load_silver AS
BEGIN

declare @start_date datetime , @end_date datetime;

begin try

print '================================================================';
print 'Loading Silver Layer'
print '================================================================'; 

print '----------------------------------------------------------------'; 
print 'Loading CRM Tables'
print '----------------------------------------------------------------'; 

set @start_date=GETDATE();
print 'Truncating Table : silver.crm_cust_info ';
truncate table silver.crm_cust_info;

print 'Inserting Data into : silver.crm_cust_info '
insert into silver.crm_cust_info (
    cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date
)
select cst_id, cst_key, TRIM(cst_firstname) as cst_firstname, TRIM(cst_lastname) as cst_lastname,
    case when upper(trim(cst_marital_status)) = 'M' then 'Married'
         when upper(trim(cst_marital_status)) = 'S' then 'Single'
         else 'n/a' end as cst_marital_status,
    case when upper(trim(cst_gndr)) = 'M' then 'Male'
         when upper(trim(cst_gndr)) = 'F' then 'Female'
         else 'n/a' end as cst_gndr,
    cst_create_date
from (
    select *, ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as flag_last 
    from bronze.crm_cust_info where cst_id is not null
) as new_table
where flag_last = 1;

set @end_date =GETDATE();
print '>> Loading silver.crm_cust_info takes '+cast(datediff(second,@start_date,@end_date) as nvarchar(50))+' seconds';
print '--------------------------------------------------------------------------------------';

set @start_date=GETDATE();
print 'Truncating Table : silver.crm_prd_info ';
truncate table silver.crm_prd_info;

print 'Inserting Data into : silver.crm_prd_info ';
insert into silver.crm_prd_info (
    prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
)
select prd_id,
    replace(SUBSTRING(prd_key, 1, 5), '-', '_') as cat_id,
    SUBSTRING(prd_key, 7, LEN(prd_key)) as prd_key,
    TRIM(prd_nm) as prd_nm,
    ISNULL(prd_cost, 0) as prd_cost,
    case when upper(trim(prd_line)) = 'M' then 'Mountain'
         when upper(trim(prd_line)) = 'R' then 'Road'
         when upper(trim(prd_line)) = 'S' then 'Other Sales'
         when upper(trim(prd_line)) = 'T' then 'Touring'
         else 'n/a' end as prd_line,
    prd_start_dt,
    dateadd(day, -1, LEAD(prd_start_dt) over (partition by prd_key order by prd_start_dt asc)) as prd_end_dt
from bronze.crm_prd_info;

set @end_date =GETDATE();
print '>> Loading silver.crm_prd_info takes '+cast(datediff(second,@start_date,@end_date) as nvarchar(50))+' seconds';
print '--------------------------------------------------------------------------------------';

set @start_date=GETDATE();
print 'Truncating Table : silver.crm_sales_details ';
truncate table silver.crm_sales_details;

print 'Inserting Data into : silver.crm_sales_details '
insert into silver.crm_sales_details (
    sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
)
select sls_ord_num, sls_prd_key, sls_cust_id,
    case when sls_order_dt <= 0 OR len(sls_order_dt) != 8 then null
         else cast(CAST(sls_order_dt as nvarchar(10)) as date) end as sls_order_dt,
    case when sls_ship_dt <= 0 OR len(sls_ship_dt) != 8 then null
         else cast(CAST(sls_ship_dt as nvarchar(10)) as date) end as sls_ship_dt,
    case when sls_due_dt <= 0 OR len(sls_due_dt) != 8 then null
         else cast(CAST(sls_due_dt as nvarchar(10)) as date) end as sls_due_dt,
    case when sls_sales IS null OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
         then sls_quantity * ABS(sls_price) else sls_sales end as sls_sales,
    sls_quantity,
    case when sls_price is null OR sls_price <= 0 OR sls_price != ABS(sls_sales) / nullif(sls_quantity, 0)
         then ABS(sls_sales) / nullif(sls_quantity, 0) else sls_price end as sls_price
from bronze.crm_sales_details;

set @end_date =GETDATE();
print '>> Loading silver.crm_sales_details takes '+cast(datediff(second,@start_date,@end_date) as nvarchar(50))+' seconds';
print '--------------------------------------------------------------------------------------';

print '----------------------------------------------------------------'; 
print 'Loading ERP Tables'
print '----------------------------------------------------------------'; 

set @start_date=GETDATE();
print 'Truncating Table : silver.erp_cust_az12 ';
truncate table silver.erp_cust_az12;

print 'Inserting Data into : silver.erp_cust_az12 ';
insert into silver.erp_cust_az12 (CID, BDATE, GEN)
select case when CID like 'NAS%' then SUBSTRING(CID, 4, len(CID)) else CID end CID,
    case when BDATE > GETDATE() then null else BDATE end BDATE,
    case when upper(trim(GEN)) in ('F', 'Female') then 'Female'
         when upper(trim(GEN)) in ('M', 'Male') then 'Male'
         else 'n/a' end as GEN
from bronze.erp_cust_az12;

set @end_date =GETDATE();
print '>> Loading  silver.erp_cust_az12 takes '+cast(datediff(second,@start_date,@end_date) as nvarchar(50))+' seconds';
print '--------------------------------------------------------------------------------------';

set @start_date=GETDATE();
print 'Truncating Table : silver.erp_loc_a101 ';
truncate table silver.erp_loc_a101;

print 'Inserting Data into : silver.erp_loc_a101 ';
insert into silver.erp_loc_a101 (CID, CNTRY)
select REPLACE(CID, '-', '') as CID,
    case when trim(CNTRY) IN ('US', 'USA', 'United States') then 'United States'
         when trim(CNTRY) IN ('DE', 'Germany') then 'Germany'
         when trim(CNTRY) = '' OR CNTRY IS null then 'n/a'
         else trim(CNTRY) end as CNTRY
from bronze.erp_loc_a101;

set @end_date =GETDATE();
print '>> Loading  silver.erp_loc_a101 takes '+cast(datediff(second,@start_date,@end_date) as nvarchar(50))+' seconds';
print '--------------------------------------------------------------------------------------';

set @start_date=GETDATE();
print 'Truncating Table : silver.erp_px_cat_g1v2 ';
truncate table silver.erp_px_cat_g1v2;

print 'Inserting Data into : silver.erp_px_cat_g1v2 ';
insert into silver.erp_px_cat_g1v2 (ID, CAT, SUBCAT, MAINTENANCE)
select TRIM(ID) as ID, TRIM(CAT) as CAT, TRIM(SUBCAT) as SUBCAT, TRIM(MAINTENANCE) as MAINTENANCE
from bronze.erp_px_cat_g1v2;

set @end_date =GETDATE();
print '>> Loading  silver.erp_px_cat_g1v2 takes '+cast(datediff(second,@start_date,@end_date) as nvarchar(50))+' seconds';
print '--------------------------------------------------------------------------------------';

end try
begin catch

print '==============================================================='
print 'Error Occured During Loading Silver Layer '
print 'Error Message : '+error_message();
print 'Error Number : '+convert(nvarchar(50),error_number());
print '==============================================================='

end catch
end
