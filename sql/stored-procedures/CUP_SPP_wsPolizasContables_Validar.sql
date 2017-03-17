SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**************** DROP IF EXISTS ****************/
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'CUP_SPP_wsPolizasContables_Validar') 
  DROP PROCEDURE  CUP_SPP_wsPolizasContables_Validar
GO

/* =============================================
  
  Created by:    Enrique Sierra Gtez
  Creation Date: 2017-03-16

  Description: Procedimiento encargado de validar
  la informacion que conforma las polizas contables
  que se ingresaran a Intelisis de parte de otros
  sistemas mediante el llamado de un web service.

============================================= */

CREATE PROCEDURE [dbo].CUP_SPP_wsPolizasContables_Validar              
AS BEGIN TRY
  PRINT('.Validando.')
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