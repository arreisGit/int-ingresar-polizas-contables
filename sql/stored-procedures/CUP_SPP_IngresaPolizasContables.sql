SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**************** DROP IF EXISTS ****************/
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'CUP_SPP_IngresaPolizasContables') 
  DROP PROCEDURE  CUP_SPP_IngresaPolizasContables
GO

/* =============================================
  
  Created by:    Enrique Sierra Gtez
  Creation Date: 2017-03-16

  Description: Procedimiento almacenado 
  encargado de insertar Polizas contables a 
  Intelisis

============================================= */

CREATE PROCEDURE [dbo].CUP_SPP_IngresaPolizasContables
(
 @Poliza XML(JournalEntrySchema)
)                
AS BEGIN TRY
  
  -- Datos del cabecero de la poliza
  IF OBJECT_ID('tempdb..#tmp_wsPolizasIntelisis_Header') IS NOT NULL
    DROP TABLE #tmp_wsPolizasIntelisis_Header

  CREATE TABLE #tmp_wsPolizasIntelisis_Header
  (
    Sistema INT  NULL,
    Tipo   VARCHAR(20)  NULL,
    FechaContable DATE,
    SucursalContable   INT NULL,
    Concepto VARCHAR(50) NULL,
    Referencia VARCHAR(50) NULL
  )

  INSERT INTO #tmp_wsPolizasIntelisis_Header
  (
    Sistema,
    Tipo,
    FechaContable,
    SucursalContable,
    Concepto,
    Referencia
  )
   SELECT  
    Sistema            = c.value('@System','INT')
    ,Tipo              = c.value('(Type)','VARCHAR(20)')
    ,FechaContable     = c.value('(EffectiveDate)[1]','DATE')
    ,SucursalContable  = c.value('(Branch)[1]','INT')
    ,Concepto          = c.value('(Concept)[1]','VARCHAR(50)')
    ,Referencia        = c.value('(Reference)[1]','VARCHAR(50)')
  FROM
    @Poliza.nodes('/JournalEntry') AS R(c)

  -- Datos del detalle de la poliza
  IF OBJECT_ID('tempdb..#tmp_wsPolizasIntelisis_Records') IS NOT NULL
    DROP TABLE #tmp_wsPolizasIntelisis_Records

  CREATE TABLE #tmp_wsPolizasIntelisis_Records
  (
    Cuenta CHAR(20) NOT NULL,
    SubCuenta VARCHAR(50) NULL,
    Concepto VARCHAR(50) NULL,
    Debe DECIMAL(18,4) NOT NULL,
    Haber DECIMAL(18,4) NOT NULL,
    MonedaOriginal CHAR(10) NULL,
    TipoCambioOriginal FLOAT NULL
  )

  DECLARE 
    @SystemID INT,
    @FechaContable DATE,
    @SucursalContable INT,
    @Concepto VARCHAR(50),
    @Referencia VARCHAR(50)

  CREATE NONCLUSTERED INDEX IX_#tmp_wsPolizasIntelisis_Records_Cuenta_Subcuenta
    ON #tmp_wsPolizasIntelisis_Records ( Cuenta, SubCuenta )
  INCLUDE 
  (
    Concepto,
    Debe,
    Haber,
    MonedaOriginal,
    TipoCambioOriginal
  )

  CREATE NONCLUSTERED INDEX IX_#tmp_wsPolizasIntelisis_Records_MonedaOriginal
    ON #tmp_wsPolizasIntelisis_Records ( MonedaOriginal)
  INCLUDE 
  (
    Cuenta,
    SubCuenta,
    Concepto,
    Debe,
    Haber,
    TipoCambioOriginal
  )

  INSERT INTO #tmp_wsPolizasIntelisis_Records
  (
    Cuenta,
    SubCuenta,
    Debe,
    Haber,
    Concepto,
    MonedaOriginal,
    TipoCambioOriginal
  )
  SELECT
    Cuenta              = c.value('(Account)[1]','varchar(100)')
    ,SubCuenta          = c.value('(CostCenter)[1]','VARCHAR(50)')
    ,Debe               = c.value('(Debit)[1]','DECIMAL(18,4)')
    ,Haber              = c.value('(Credit)[1]','DECIMAL(18,4)')
    ,Concepto           = c.value('(Concept)[1]','VARCHAR(50)')
    ,MonedaOriginal     = c.value('(OriginalCurrency)[1]','CHAR(10)')
    ,TipoCambioOriginal = c.value('(OriginalExchangeRate)[1]','FLOAT') 
  FROM
    @Poliza.nodes('/JournalEntry/Records/Record') AS R(c)

  SELECT
    Sistema,
    Tipo,
    FechaContable,
    SucursalContable,
    Concepto,
    Referencia
  FROM 
   #tmp_wsPolizasIntelisis_Header

  SELECT 
    Cuenta,
    SubCuenta,
    Debe,
    Haber,
    Concepto,
    MonedaOriginal,
    TipoCambioOriginal
  FROM 
    #tmp_wsPolizasIntelisis_Records

  -- Contenedor de los mensajes de respuesta del proceso. 
  IF OBJECT_ID('tempdb..#tmp_wsPolizasIntelisis_Messages') IS NOT NULL
    DROP TABLE #tmp_wsPolizasIntelisis_Messages

  CREATE TABLE #tmp_wsPolizasIntelisis_Messages
  (
    Num INT NOT NULL,
    [Description] VARCHAR(255) NOT NULL,
    ID INT NULL,
    Mov VARCHAR(20) NULL,
    MovID VARCHAR(20) NULL
  )

  -- Validacion de la informacion

  -- Creacion de la poliza

  -- Verificacion y afectacion de la poliza

  IF NOT EXISTS(SELECT [Description] FROM #tmp_wsPolizasIntelisis_Messages)
    INSERT INTO #tmp_wsPolizasIntelisis_Messages ( NUM , [Description] )
    VALUES ( '2', 'Unhandled Error... Please contact the CML-Planos team')

  SELECT
    Num
    ,[Description] = ISNULL([Description],'')
    ,ID = ISNULL(CAST(ID AS VARCHAR(30)),'')
    ,Mov = ISNULL(Mov,'')
    ,MovID = ISNULL(MovID,'')
  FROM
    #tmp_wsPolizasIntelisis_Messages

END TRY
BEGIN CATCH
  SELECT
    Num = ERROR_NUMBER()
    ,[Description] = ERROR_MESSAGE()
    ,ID = ''
    ,Mov = ''
    ,MovID = ''
END CATCH