SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**************** DROP IF EXISTS ****************/
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'CUP_SPI_PolizasContables') 
  DROP PROCEDURE  CUP_SPI_PolizasContables
GO

/* =============================================
  Created by:    Enrique Sierra Gtez
  Creation Date: 2017-03-09

  Description: Procedimiento almacenado 
  encargado de insertar Polizas contables a 
  Intelisis

============================================= */

CREATE PROCEDURE [dbo].CUP_SPI_PolizasContables
(
 @Poliza XML   
)                
AS BEGIN   

  SELECT 'Oh yeah!'
END