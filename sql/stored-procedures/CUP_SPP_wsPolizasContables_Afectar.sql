SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**************** DROP IF EXISTS ****************/
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'CUP_SPP_wsPolizasContables_Afectar') 
  DROP PROCEDURE  CUP_SPP_wsPolizasContables_Afectar
GO

/* =============================================
  
  Created by:    Enrique Sierra Gtez
  Creation Date: 2017-03-16

  Description: Procedimiento encargado de afectar y verificar
  las polizas contables que se ingresaran a Intelisis
  de parte de otros sistemas mediante el llamado de un
  web service.

============================================= */

CREATE PROCEDURE [dbo].CUP_SPP_wsPolizasContables_Afectar 
  @VerificarSinAfectar BIT = 0            
AS BEGIN TRY
  PRINT('.Afectando.')

  -- Mensaje temporal de pruebas.
  IF NOT EXISTS
  (
    SELECT
      [Description]
    FROM
      #tmp_wsPolizasIntelisis_Messages
    WHERE
      ISNULL(Num,0) > 0
  )
  BEGIN
    INSERT INTO
      #tmp_wsPolizasIntelisis_Messages
    ( 
      NUM,
      [Description],
      ID,
      Mov,
      MovID
    )
    SELECT 
      Num = 0,
      [Description] = 'Poliza Creada Exitosamente',
      ID = 1,
      Mov = header.Tipo,
      MovID = LTRIM(RTRIM(ISNULL(suc.Prefijo,''))) + '1'
    FROM
      #tmp_wsPolizasIntelisis_Header header
     LEFT JOIN Sucursal suc ON suc.Sucursal = header.SucursalContable

  END
    
END TRY
BEGIN CATCH
 IF OBJECT_ID('tempdb..#tmp_wsPolizasIntelisis_Messages') IS NOT NULL
 BEGIN
    INSERT INTO #tmp_wsPolizasIntelisis_Messages
    ( 
      NUM, 
      [Description] 
    )
    SELECT 
      Num =  ERROR_NUMBER()
     ,[Description] = ERROR_MESSAGE()
 END
 ELSE
 BEGIN
    SELECT
    Num = ERROR_NUMBER()
    ,[Description] = ERROR_MESSAGE()
    ,ID = ''
    ,Mov = ''
    ,MovID = ''
  END
  
END CATCH