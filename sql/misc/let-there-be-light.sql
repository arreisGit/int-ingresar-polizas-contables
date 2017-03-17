IF OBJECT_ID('dbo.CUP_SistemasCuprum', 'U') IS NOT NULL 
  DROP TABLE dbo.CUP_SistemasCuprum;

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'CUP_SPP_wsPolizasContables') 
  DROP PROCEDURE  CUP_SPP_wsPolizasContables

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'CUP_SPP_wsPolizasContables_Validacion') 
  DROP PROCEDURE  CUP_SPP_wsPolizasContables_Validacion

IF EXISTS (SELECT name 
           FROM sys.xml_schema_collections
           WHERE name='JournalEntrySchema')
  DROP XML SCHEMA COLLECTION JournalEntrySchema