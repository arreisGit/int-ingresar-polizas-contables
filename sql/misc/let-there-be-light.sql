IF OBJECT_ID('dbo.CUP_SistemasCuprum', 'U') IS NOT NULL 
  DROP TABLE dbo.CUP_SistemasCuprum;

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'CUP_SPI_PolizasContables') 
  DROP PROCEDURE  CUP_SPI_PolizasContables

IF EXISTS (SELECT name 
           FROM sys.xml_schema_collections
           WHERE name='JournalEntrySchema')
  DROP XML SCHEMA COLLECTION JournalEntrySchema