/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
*/

USE master;

GO

if exists (select 1 from sys.databases where name ='datawarehouse')
drop database datawarehouse

GO

create database datawarehouse;

GO

use datawarehouse;

GO

create schema bronze;
GO
create schema silver;
GO
create schema gold;
GO

select name from sys.schemas    -- Testing
