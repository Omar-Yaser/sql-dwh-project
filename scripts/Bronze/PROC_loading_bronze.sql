/*
Stored Procedure : Loading Bronze Layer
---------------------------------------------------------------------
Script Purpose :
 - This SP loads data from external files (6 CSV Files) into 'Bronze' Schema
 - It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables. 
*/

create or alter proc bronze.load_bronze as
begin

declare @start_date datetime , @end_date datetime;

begin try

print '================================================================';
print 'Loading Bronze Layer'
print '================================================================'; 

print '----------------------------------------------------------------'; 
print 'Loading CRM Tables'
print '----------------------------------------------------------------'; 

set @start_date=GETDATE();

print 'Truncating Table : bronze.crm_cust_info ';
truncate table bronze.crm_cust_info;

print 'Inserting Data into : bronze.crm_cust_info '
bulk insert bronze.crm_cust_info
from 'c:\users\omar yasser\desktop\data engineering\project 1 (dwh baraa)\datasets\source_crm\cust_info.csv'
with (
    fieldterminator = ',',
    rowterminator = '\n',
    firstrow = 2,
    tablock,
    errorfile = 'c:\users\omar yasser\desktop\data engineering\project 1 (dwh baraa)\error_logs\crm_cust_info_err.txt'
);
set @end_date =GETDATE();

print '>> Loading bronze.crm_cust_info takes '+cast(datediff(second,@start_date,@end_date) as nvarchar(50))+' seconds';
print '--------------------------------------------------------------------------------------';

set @start_date=GETDATE();
print 'Truncating Table : bronze.crm_prd_info ';
truncate table bronze.crm_prd_info;

print 'Inserting Data into : bronze.crm_prd_info ';
bulk insert bronze.crm_prd_info
from 'c:\users\omar yasser\desktop\data engineering\project 1 (dwh baraa)\datasets\source_crm\prd_info.csv'
with (
    fieldterminator = ',',
    rowterminator = '\n',
    firstrow = 2,
    tablock,
    errorfile = 'c:\users\omar yasser\desktop\data engineering\project 1 (dwh baraa)\error_logs\crm_prd_info_err.txt'
);
set @end_date =GETDATE();

print '>> Loading bronze.crm_prd_info takes '+cast(datediff(second,@start_date,@end_date) as nvarchar(50))+' seconds';
print '--------------------------------------------------------------------------------------';

set @start_date=GETDATE();
print 'Truncating Table : bronze.crm_sales_details ';
truncate table bronze.crm_sales_details;

print 'Inserting Data into : bronze.crm_sales_details '
bulk insert bronze.crm_sales_details
from 'c:\users\omar yasser\desktop\data engineering\project 1 (dwh baraa)\datasets\source_crm\sales_details.csv'
with (
    fieldterminator = ',',
    rowterminator = '\n',
    firstrow = 2,
    tablock,
    errorfile = 'c:\users\omar yasser\desktop\data engineering\project 1 (dwh baraa)\error_logs\crm_sales_details_err.txt'
);
set @end_date =GETDATE();

print '>> Loading bronze.crm_sales_details takes '+cast(datediff(second,@start_date,@end_date) as nvarchar(50))+' seconds';
print '--------------------------------------------------------------------------------------';

print '----------------------------------------------------------------'; 
print 'Loading ERP Tables'
print '----------------------------------------------------------------'; 

set @start_date=GETDATE();

print 'Truncating Table : bronze.erp_cust_az12 ';
truncate table bronze.erp_cust_az12;

print 'Inserting Data into : bronze.erp_cust_az12 ';
bulk insert bronze.erp_cust_az12
from 'c:\users\omar yasser\desktop\data engineering\project 1 (dwh baraa)\datasets\source_erp\cust_az12.csv'
with (
    fieldterminator = ',',
    rowterminator = '\n',
    firstrow = 2,
    tablock,
    errorfile = 'c:\users\omar yasser\desktop\data engineering\project 1 (dwh baraa)\error_logs\erp_cust_az12_err.txt'
);

set @end_date =GETDATE();

print '>> Loading  bronze.erp_cust_az12 takes '+cast(datediff(second,@start_date,@end_date) as nvarchar(50))+' seconds';
print '--------------------------------------------------------------------------------------';

set @start_date=GETDATE();
print 'Truncating Table : bronze.erp_loc_a101 ';
truncate table bronze.erp_loc_a101;

print 'Inserting Data into : bronze.erp_loc_a101 ';
bulk insert bronze.erp_loc_a101
from 'c:\users\omar yasser\desktop\data engineering\project 1 (dwh baraa)\datasets\source_erp\loc_a101.csv'
with (
    fieldterminator = ',',
    rowterminator = '\n',
    firstrow = 2,
    tablock,
    errorfile = 'c:\users\omar yasser\desktop\data engineering\project 1 (dwh baraa)\error_logs\erp_loc_a101_err.txt'
);

set @end_date =GETDATE();

print '>> Loading  bronze.erp_loc_a101 takes '+cast(datediff(second,@start_date,@end_date) as nvarchar(50))+' seconds';
print '--------------------------------------------------------------------------------------';

set @start_date=GETDATE();
print 'Truncating Table : bronze.erp_px_cat_g1v2 ';
truncate table bronze.erp_px_cat_g1v2;

print 'Inserting Data into : bronze.erp_px_cat_g1v2 ';
bulk insert bronze.erp_px_cat_g1v2
from 'c:\users\omar yasser\desktop\data engineering\project 1 (dwh baraa)\datasets\source_erp\px_cat_g1v2.csv'
with (
    fieldterminator = ',',
    rowterminator = '\n',
    firstrow = 2,
    tablock,
    errorfile = 'c:\users\omar yasser\desktop\data engineering\project 1 (dwh baraa)\error_logs\erp_px_cat_g1v2_err.txt'
);


set @end_date =GETDATE();

print '>> Loading  bronze.erp_px_cat_g1v2 takes '+cast(datediff(second,@start_date,@end_date) as nvarchar(50))+' seconds';
print '--------------------------------------------------------------------------------------';

end try

begin catch

print '===============================================================';
print 'Error Occured During Loading Bronze Layer ';
print 'Error Message : '+error_message();
print 'Error Number : '+convert(nvarchar(50),error_number());
print '===============================================================';

end catch

end
