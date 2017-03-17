IF OBJECT_ID('dbo.CUP_SistemasCuprum', 'U') IS NOT NULL 
  DROP TABLE dbo.CUP_SistemasCuprum;

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'CUP_SPP_wsPolizasContables') 
  DROP PROCEDURE  CUP_SPP_wsPolizasContables

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'CUP_SPP_wsPolizasContables_Validar') 
  DROP PROCEDURE  CUP_SPP_wsPolizasContables_Validar

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'CUP_SPP_wsPolizasContables_Insertar') 
  DROP PROCEDURE  CUP_SPP_wsPolizasContables_Insertar

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'CUP_SPP_wsPolizasContables_Afectar') 
  DROP PROCEDURE  CUP_SPP_wsPolizasContables_Afectar

IF EXISTS (SELECT name 
           FROM sys.xml_schema_collections
           WHERE name='JournalEntrySchema')
  DROP XML SCHEMA COLLECTION JournalEntrySchema